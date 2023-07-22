/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2023, Ankit Sangwan
 */

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/Screens/Player/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MiniPlayer extends StatefulWidget {
  static const MiniPlayer _instance = MiniPlayer._internal();

  factory MiniPlayer() {
    return _instance;
  }

  const MiniPlayer._internal();

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool rotated = screenHeight < screenWidth;
    return SafeArea(
      top: false,
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          // if (snapshot.connectionState != ConnectionState.active) {
          //   return const SizedBox();
          // }
          final MediaItem? mediaItem = snapshot.data;
          // if (mediaItem == null) return const SizedBox();
          return Dismissible(
            key: const Key('miniplayer'),
            direction: DismissDirection.vertical,
            confirmDismiss: (DismissDirection direction) {
              if (mediaItem != null) {
                if (direction == DismissDirection.down) {
                  audioHandler.stop();
                } else {
                  Navigator.pushNamed(context, '/player');
                }
              }
              return Future.value(false);
            },
            child: Dismissible(
              key: Key(mediaItem?.id ?? 'nothingPlaying'),
              // background: Container(color: Colors.red),
              confirmDismiss: (DismissDirection direction) {
                if (mediaItem != null) {
                  if (direction == DismissDirection.startToEnd) {
                    audioHandler.skipToPrevious();
                  } else {
                    audioHandler.skipToNext();
                  }
                }
                return Future.value(false);
              },
              child: ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                child:
                    positionSlider(mediaItem?.duration?.inSeconds.toDouble()),
                builder: (BuildContext context, Box box1, Widget? child) {
                  final bool useDense = box1.get(
                        'useDenseMini',
                        defaultValue: false,
                      ) as bool ||
                      rotated;
                  final List preferredMiniButtons = Hive.box('settings').get(
                    'preferredMiniButtons',
                    defaultValue: ['Like', 'Play/Pause', 'Next'],
                  )?.toList() as List;

                  final bool isLocal =
                      mediaItem?.artUri?.toString().startsWith('file:') ??
                          false;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2.0,
                      vertical: 1.0,
                    ),
                    elevation: 0,
                    child: SizedBox(
                      height: useDense ? 68.0 : 76.0,
                      child: GradientContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            miniplayerTile(
                              context: context,
                              preferredMiniButtons: preferredMiniButtons,
                              useDense: useDense,
                              title: mediaItem?.title ?? '',
                              subtitle: mediaItem?.artist ?? '',
                              imagePath: (isLocal
                                      ? mediaItem?.artUri?.toFilePath()
                                      : mediaItem?.artUri?.toString()) ??
                                  '',
                              isLocalImage: isLocal,
                              isDummy: mediaItem == null,
                            ),
                            child!,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  ListTile miniplayerTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required List preferredMiniButtons,
    bool useDense = false,
    bool isLocalImage = false,
    bool isDummy = false,
  }) {
    return ListTile(
      dense: useDense,
      onTap: isDummy
          ? null
          : () {
              Navigator.pushNamed(context, '/player');
            },
      title: Text(
        isDummy ? 'Now Playing' : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isDummy ? 'Unknown' : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Hero(
        tag: 'currentArtwork',
        child: Card(
          elevation: 8,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox.square(
            dimension: useDense ? 40.0 : 50.0,
            child: isLocalImage
                ? Image(
                    fit: BoxFit.cover,
                    image: FileImage(
                      File(imagePath),
                    ),
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Image(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/cover.jpg',
                        ),
                      );
                    },
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget: (
                      BuildContext context,
                      _,
                      __,
                    ) =>
                        const Image(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/cover.jpg',
                      ),
                    ),
                    placeholder: (
                      BuildContext context,
                      _,
                    ) =>
                        const Image(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/cover.jpg',
                      ),
                    ),
                    imageUrl: imagePath,
                  ),
          ),
        ),
      ),
      trailing: isDummy
          ? null
          : ControlButtons(
              audioHandler,
              miniplayer: true,
              buttons: isLocalImage
                  ? ['Like', 'Play/Pause', 'Next']
                  : preferredMiniButtons,
            ),
    );
  }

  StreamBuilder<Duration> positionSlider(double? maxDuration) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data;
        return position == null
            ? const SizedBox()
            : (position.inSeconds.toDouble() < 0.0 ||
                    (position.inSeconds.toDouble() > (maxDuration ?? 180.0)))
                ? const SizedBox()
                : SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Colors.transparent,
                      trackHeight: 0.5,
                      thumbColor: Theme.of(context).colorScheme.secondary,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 1.0,
                      ),
                      overlayColor: Colors.transparent,
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Slider(
                        inactiveColor: Colors.transparent,
                        // activeColor: Colors.white,
                        value: position.inSeconds.toDouble(),
                        max: maxDuration ?? 180.0,
                        onChanged: (newPosition) {
                          audioHandler.seek(
                            Duration(
                              seconds: newPosition.round(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
      },
    );
  }
}
