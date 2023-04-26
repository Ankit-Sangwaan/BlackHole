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
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audio_service/audio_service.dart';
import 'package:blackhole/CustomWidgets/add_playlist.dart';
import 'package:blackhole/CustomWidgets/animated_text.dart';
import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/download_button.dart';
import 'package:blackhole/CustomWidgets/empty_screen.dart';
import 'package:blackhole/CustomWidgets/equalizer.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/like_button.dart';
import 'package:blackhole/CustomWidgets/popup.dart';
import 'package:blackhole/CustomWidgets/seek_bar.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/textinput_dialog.dart';
import 'package:blackhole/Helpers/config.dart';
import 'package:blackhole/Helpers/dominant_color.dart';
import 'package:blackhole/Helpers/lyrics.dart';
import 'package:blackhole/Helpers/mediaitem_converter.dart';
import 'package:blackhole/Screens/Common/song_list.dart';
import 'package:blackhole/Screens/Search/albums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();
  final bool getLyricsOnline =
      Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;

  final MyTheme currentTheme = GetIt.I<MyTheme>();
  final ValueNotifier<List<Color?>?> gradientColor =
      ValueNotifier<List<Color?>?>(GetIt.I<MyTheme>().playGradientColor);
  final PanelController _panelController = PanelController();
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late Duration _time;

  void sleepTimer(int time) {
    audioHandler.customAction('sleepTimer', {'time': time});
  }

  void sleepCounter(int count) {
    audioHandler.customAction('sleepCounter', {'count': count});
  }

  Future<dynamic> setTimer(
    BuildContext context,
    BuildContext? scaffoldContext,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.selectDur,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: Theme.of(context).colorScheme.secondary,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(0);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor:
                        Theme.of(context).colorScheme.secondary == Colors.white
                            ? Colors.black
                            : Colors.white,
                  ),
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ShowSnackBar().showSnackBar(
                      context,
                      '${AppLocalizations.of(context)!.sleepTimerSetFor} ${_time.inMinutes} ${AppLocalizations.of(context)!.minutes}',
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> setCounter() async {
    await showTextInputDialog(
      context: context,
      title: AppLocalizations.of(context)!.enterSongsCount,
      initialText: '',
      keyboardType: TextInputType.number,
      onSubmitted: (String value) {
        sleepCounter(
          int.parse(value),
        );
        Navigator.pop(context);
        ShowSnackBar().showSnackBar(
          context,
          '${AppLocalizations.of(context)!.sleepTimerSetFor} $value ${AppLocalizations.of(context)!.songs}',
        );
      },
    );
  }

  void updateBackgroundColors(List<Color?> value) {
    gradientColor.value = value;
    return;
  }

  String format(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}'.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? scaffoldContext;

    return Dismissible(
      direction: DismissDirection.down,
      background: const ColoredBox(color: Colors.transparent),
      key: const Key('playScreen'),
      onDismissed: (direction) {
        Navigator.pop(context);
      },
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox();
          final offline =
              !mediaItem.extras!['url'].toString().startsWith('http');
          mediaItem.artUri.toString().startsWith('file')
              ? getColors(
                  imageProvider: FileImage(
                    File(
                      mediaItem.artUri!.toFilePath(),
                    ),
                  ),
                  // useDominantAndDarkerColors: gradientType == 'halfLight' ||
                  //     gradientType == 'fullLight' ||
                  //     gradientType == 'fullMix',
                ).then((value) => updateBackgroundColors(value))
              : getColors(
                  imageProvider: CachedNetworkImageProvider(
                    mediaItem.artUri.toString(),
                  ),
                  // useDominantAndDarkerColors: gradientType == 'halfLight' ||
                  //     gradientType == 'fullLight' ||
                  //     gradientType == 'fullMix',
                ).then((value) => updateBackgroundColors(value));
          return ValueListenableBuilder(
            valueListenable: gradientColor,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.expand_more_rounded),
                    tooltip: AppLocalizations.of(context)!.back,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.lyrics_rounded),
                      //     Image.asset(
                      //   'assets/lyrics.png',
                      // ),
                      tooltip: AppLocalizations.of(context)!.lyrics,
                      onPressed: () => cardKey.currentState!.toggleCard(),
                    ),
                    if (!offline)
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        tooltip: AppLocalizations.of(context)!.share,
                        onPressed: () {
                          Share.share(
                            mediaItem.extras!['perma_url'].toString(),
                          );
                        },
                      ),
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      onSelected: (int? value) {
                        if (value == 10) {
                          final Map details =
                              MediaItemConverter.mediaItemToMap(mediaItem);
                          details['duration'] =
                              '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                          // style: Theme.of(context).textTheme.caption,
                          if (mediaItem.extras?['size'] != null) {
                            details.addEntries([
                              MapEntry(
                                'date_modified',
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(
                                        mediaItem.extras!['date_modified']
                                            .toString(),
                                      ) *
                                      1000,
                                ).toString().split('.').first,
                              ),
                              MapEntry(
                                'size',
                                '${((mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                              ),
                            ]);
                          }
                          PopupDialog().showPopup(
                            context: context,
                            child: GradientCard(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: details.keys.map((e) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: SelectableText.rich(
                                        TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: format(
                                                '$e\n',
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .color,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${details[e]}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        showCursor: true,
                                        cursorColor: Colors.black,
                                        cursorRadius: const Radius.circular(5),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }
                        if (value == 5) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) => SongsListPage(
                                listItem: {
                                  'type': 'album',
                                  'id': mediaItem.extras?['album_id'],
                                  'title': mediaItem.album,
                                  'image': mediaItem.artUri,
                                },
                              ),
                            ),
                          );
                        }
                        if (value == 4) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Equalizer();
                            },
                          );
                        }
                        if (value == 3) {
                          launchUrl(
                            Uri.parse(
                              mediaItem.genre == 'YouTube'
                                  ? 'https://youtube.com/watch?v=${mediaItem.id}'
                                  : 'https://www.youtube.com/results?search_query=${mediaItem.title} by ${mediaItem.artist}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        if (value == 1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.sleepTimer,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(10.0),
                                children: [
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.sleepDur,
                                    ),
                                    subtitle: Text(
                                      AppLocalizations.of(context)!.sleepDurSub,
                                    ),
                                    dense: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setTimer(
                                        context,
                                        scaffoldContext,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.sleepAfter,
                                    ),
                                    subtitle: Text(
                                      AppLocalizations.of(context)!
                                          .sleepAfterSub,
                                    ),
                                    dense: true,
                                    isThreeLine: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setCounter();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        if (value == 0) {
                          AddToPlaylist().addToPlaylist(context, mediaItem);
                        }
                      },
                      itemBuilder: (context) => offline
                          ? [
                              if (mediaItem.extras?['album_id'] != null)
                                PopupMenuItem(
                                  value: 5,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.album_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        AppLocalizations.of(context)!.viewAlbum,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.timer,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!.sleepTimer,
                                    ),
                                  ],
                                ),
                              ),
                              if (Hive.box('settings').get(
                                'supportEq',
                                defaultValue: false,
                              ) as bool)
                                PopupMenuItem(
                                  value: 4,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.equalizer_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        AppLocalizations.of(context)!.equalizer,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!.songInfo,
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          : [
                              if (mediaItem.extras?['album_id'] != null)
                                PopupMenuItem(
                                  value: 5,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.album_rounded,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        AppLocalizations.of(context)!.viewAlbum,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.playlist_add_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .addToPlaylist,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.timer,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!.sleepTimer,
                                    ),
                                  ],
                                ),
                              ),
                              if (Hive.box('settings').get(
                                'supportEq',
                                defaultValue: false,
                              ) as bool)
                                PopupMenuItem(
                                  value: 4,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.equalizer_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        AppLocalizations.of(context)!.equalizer,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    Icon(
                                      MdiIcons.youtube,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      mediaItem.genre == 'YouTube'
                                          ? AppLocalizations.of(
                                              context,
                                            )!
                                              .watchVideo
                                          : AppLocalizations.of(
                                              context,
                                            )!
                                              .searchVideo,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!.songInfo,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                    )
                  ],
                ),
                body: LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    if (constraints.maxWidth > constraints.maxHeight) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Artwork
                          ArtWorkWidget(
                            cardKey: cardKey,
                            mediaItem: mediaItem,
                            width: min(
                              constraints.maxHeight / 0.9,
                              constraints.maxWidth / 1.8,
                            ),
                            audioHandler: audioHandler,
                            offline: offline,
                            getLyricsOnline: getLyricsOnline,
                          ),

                          // title and controls
                          NameNControls(
                            mediaItem: mediaItem,
                            offline: offline,
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            panelController: _panelController,
                            audioHandler: audioHandler,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        // Artwork
                        ArtWorkWidget(
                          cardKey: cardKey,
                          mediaItem: mediaItem,
                          width: constraints.maxWidth,
                          audioHandler: audioHandler,
                          offline: offline,
                          getLyricsOnline: getLyricsOnline,
                        ),

                        // title and controls
                        NameNControls(
                          mediaItem: mediaItem,
                          offline: offline,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight -
                              (constraints.maxWidth * 0.85),
                          panelController: _panelController,
                          audioHandler: audioHandler,
                        ),
                      ],
                    );
                  },
                ),
                // }
              ),
            ),
            builder:
                (BuildContext context, List<Color?>? value, Widget? child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: gradientType == 'simple'
                        ? Alignment.topLeft
                        : Alignment.topCenter,
                    end: gradientType == 'simple'
                        ? Alignment.bottomRight
                        : (gradientType == 'halfLight' ||
                                gradientType == 'halfDark')
                            ? Alignment.center
                            : Alignment.bottomCenter,
                    colors: gradientType == 'simple'
                        ? Theme.of(context).brightness == Brightness.dark
                            ? currentTheme.getBackGradient()
                            : [
                                const Color(0xfff5f9ff),
                                Colors.white,
                              ]
                        : Theme.of(context).brightness == Brightness.dark
                            ? [
                                if (gradientType == 'halfDark' ||
                                    gradientType == 'fullDark')
                                  value?[1] ?? Colors.grey[900]!
                                else
                                  value?[0] ?? Colors.grey[900]!,
                                if (gradientType == 'fullMix')
                                  value?[1] ?? Colors.black
                                else
                                  Colors.black
                              ]
                            : [
                                value?[0] ?? const Color(0xfff5f9ff),
                                Colors.white,
                              ],
                  ),
                ),
                child: child,
              );
            },
          );
          // );
        },
      ),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
    this.queue,
    this.queueIndex,
    this.shuffleIndices,
    this.repeatMode,
  );

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  const ControlButtons(
    this.audioHandler, {
    this.shuffle = false,
    this.miniplayer = false,
    this.buttons = const ['Previous', 'Play/Pause', 'Next'],
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final MediaItem mediaItem = audioHandler.mediaItem.value!;
    final bool online = mediaItem.extras!['url'].toString().startsWith('http');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((e) {
        switch (e) {
          case 'Like':
            return !online
                ? const SizedBox()
                : LikeButton(
                    mediaItem: mediaItem,
                    size: 22.0,
                  );
          case 'Previous':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: AppLocalizations.of(context)!.skipPrevious,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasPrevious ?? true
                      ? audioHandler.skipToPrevious
                      : null,
                );
              },
            );
          case 'Play/Pause':
            return SizedBox(
              height: miniplayer ? 40.0 : 65.0,
              width: miniplayer ? 40.0 : 65.0,
              child: StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  final playing = playbackState?.playing ?? true;
                  return Stack(
                    children: [
                      if (processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering)
                        Center(
                          child: SizedBox(
                            height: miniplayer ? 40.0 : 65.0,
                            width: miniplayer ? 40.0 : 65.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).iconTheme.color!,
                              ),
                            ),
                          ),
                        ),
                      if (miniplayer)
                        Center(
                          child: playing
                              ? IconButton(
                                  tooltip: AppLocalizations.of(context)!.pause,
                                  onPressed: audioHandler.pause,
                                  icon: const Icon(
                                    Icons.pause_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                )
                              : IconButton(
                                  tooltip: AppLocalizations.of(context)!.play,
                                  onPressed: audioHandler.play,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        )
                      else
                        Center(
                          child: SizedBox(
                            height: 59,
                            width: 59,
                            child: Center(
                              child: playing
                                  ? FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          AppLocalizations.of(context)!.pause,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.pause,
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    )
                                  : FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          AppLocalizations.of(context)!.play,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.play,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          case 'Next':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: AppLocalizations.of(context)!.skipNext,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasNext ?? true
                      ? audioHandler.skipToNext
                      : null,
                );
              },
            );
          case 'Download':
            return !online
                ? const SizedBox()
                : DownloadButton(
                    size: 20.0,
                    icon: 'download',
                    data: MediaItemConverter.mediaItemToMap(mediaItem),
                  );
          default:
            break;
        }
        return const SizedBox();
      }).toList(),
    );
  }
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}

class NowPlayingStream extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final ScrollController? scrollController;
  final PanelController? panelController;
  final bool head;
  final double headHeight;

  const NowPlayingStream({
    required this.audioHandler,
    this.scrollController,
    this.panelController,
    this.head = false,
    this.headHeight = 50,
  });

  void _updateScrollController(
    ScrollController? controller,
    int itemIndex,
    int queuePosition,
    int queueLength,
  ) {
    if (panelController != null && !panelController!.isPanelOpen) {
      if (queuePosition > 3) {
        controller?.animateTo(
          itemIndex * 72 + 12,
          curve: Curves.linear,
          duration: const Duration(
            milliseconds: 350,
          ),
        );
      } else if (queuePosition < 4 && queueLength > 4) {
        controller?.animateTo(
          (queueLength - 4) * 72 + 12,
          curve: Curves.linear,
          duration: const Duration(
            milliseconds: 350,
          ),
        );
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        final int queueStateIndex = queueState.queueIndex ?? 0;
        final num queuePosition = queue.length - queueStateIndex;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _updateScrollController(
            scrollController,
            queueState.queueIndex ?? 0,
            queuePosition.toInt(),
            queue.length,
          ),
        );

        return ReorderableListView.builder(
          header: SizedBox(
            height: head ? headHeight : 0,
          ),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex--;
            }
            audioHandler.moveQueueItem(oldIndex, newIndex);
          },
          scrollController: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 10),
          shrinkWrap: true,
          itemCount: queue.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(queue[index].id),
              direction: index == queueState.queueIndex
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (dir) {
                audioHandler.removeQueueItemAt(index);
              },
              child: ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 10.0),
                  selected: index == queueState.queueIndex,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: (index == queueState.queueIndex)
                        ? [
                            IconButton(
                              icon: const Icon(
                                Icons.bar_chart_rounded,
                              ),
                              tooltip: AppLocalizations.of(context)!.playing,
                              onPressed: () {},
                            )
                          ]
                        : [
                            if (queue[index]
                                .extras!['url']
                                .toString()
                                .startsWith('http')) ...[
                              LikeButton(
                                mediaItem: queue[index],
                              ),
                              DownloadButton(
                                icon: 'download',
                                size: 25.0,
                                data: {
                                  'id': queue[index].id,
                                  'artist': queue[index].artist.toString(),
                                  'album': queue[index].album.toString(),
                                  'image': queue[index].artUri.toString(),
                                  'duration': queue[index]
                                      .duration!
                                      .inSeconds
                                      .toString(),
                                  'title': queue[index].title,
                                  'url': queue[index].extras?['url'].toString(),
                                  'year':
                                      queue[index].extras?['year'].toString(),
                                  'language': queue[index]
                                      .extras?['language']
                                      .toString(),
                                  'genre': queue[index].genre?.toString(),
                                  '320kbps': queue[index].extras?['320kbps'],
                                  'has_lyrics':
                                      queue[index].extras?['has_lyrics'],
                                  'release_date':
                                      queue[index].extras?['release_date'],
                                  'album_id': queue[index].extras?['album_id'],
                                  'subtitle': queue[index].extras?['subtitle'],
                                  'perma_url':
                                      queue[index].extras?['perma_url'],
                                },
                              )
                            ],
                            ReorderableDragStartListener(
                              key: Key(queue[index].id),
                              index: index,
                              enabled: index != queueState.queueIndex,
                              child: const Icon(Icons.drag_handle_rounded),
                            ),
                          ],
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (queue[index].extras?['addedByAutoplay'] as bool? ??
                          false)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    AppLocalizations.of(context)!.addedBy,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 5.0,
                                    ),
                                  ),
                                ),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    AppLocalizations.of(context)!.autoplay,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      Card(
                        elevation: 5,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (queue[index].artUri == null)
                            ? const SizedBox.square(
                                dimension: 50,
                                child: Image(
                                  image: AssetImage('assets/cover.jpg'),
                                ),
                              )
                            : SizedBox.square(
                                dimension: 50,
                                child: queue[index]
                                        .artUri
                                        .toString()
                                        .startsWith('file:')
                                    ? Image(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(
                                            queue[index].artUri!.toFilePath(),
                                          ),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (BuildContext context, _, __) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        placeholder:
                                            (BuildContext context, _) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        imageUrl:
                                            queue[index].artUri.toString(),
                                      ),
                              ),
                      ),
                    ],
                  ),
                  title: Text(
                    queue[index].title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: index == queueState.queueIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    queue[index].artist!,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    audioHandler.skipToQueueItem(index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ArtWorkWidget extends StatefulWidget {
  final GlobalKey<FlipCardState> cardKey;
  final MediaItem mediaItem;
  final bool offline;
  final bool getLyricsOnline;
  final double width;
  final AudioPlayerHandler audioHandler;

  const ArtWorkWidget({
    required this.cardKey,
    required this.mediaItem,
    required this.width,
    this.offline = false,
    required this.getLyricsOnline,
    required this.audioHandler,
  });

  @override
  _ArtWorkWidgetState createState() => _ArtWorkWidgetState();
}

class _ArtWorkWidgetState extends State<ArtWorkWidget> {
  final ValueNotifier<bool> dragging = ValueNotifier<bool>(false);
  final ValueNotifier<bool> tapped = ValueNotifier<bool>(false);
  final ValueNotifier<int> doubletapped = ValueNotifier<int>(0);
  final ValueNotifier<bool> done = ValueNotifier<bool>(false);
  Map lyrics = {'id': '', 'lyrics': ''};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width * 0.85,
      width: widget.width * 0.85,
      child: Hero(
        tag: 'currentArtwork',
        child: FlipCard(
          key: widget.cardKey,
          flipOnTouch: false,
          onFlipDone: (value) {
            if (lyrics['id'] != widget.mediaItem.id ||
                (!value && lyrics['lyrics'] == '' && !done.value)) {
              done.value = false;
              if (widget.offline) {
                Lyrics.getOffLyrics(
                  widget.mediaItem.extras!['url'].toString(),
                ).then((value) {
                  if (value == '' && widget.getLyricsOnline) {
                    Lyrics.getLyrics(
                      id: widget.mediaItem.id,
                      saavnHas:
                          widget.mediaItem.extras?['has_lyrics'] == 'true',
                      title: widget.mediaItem.title,
                      artist: widget.mediaItem.artist.toString(),
                    ).then((value) {
                      lyrics['lyrics'] = value;
                      lyrics['id'] = widget.mediaItem.id;
                      done.value = true;
                    });
                  } else {
                    lyrics['lyrics'] = value;
                    lyrics['id'] = widget.mediaItem.id;
                    done.value = true;
                  }
                });
              } else {
                Lyrics.getLyrics(
                  id: widget.mediaItem.id,
                  saavnHas: widget.mediaItem.extras?['has_lyrics'] == 'true',
                  title: widget.mediaItem.title,
                  artist: widget.mediaItem.artist.toString(),
                ).then((value) {
                  lyrics['lyrics'] = value;
                  lyrics['id'] = widget.mediaItem.id;
                  done.value = true;
                });
              }
            }
          },
          back: GestureDetector(
            onTap: () => widget.cardKey.currentState!.toggleCard(),
            onDoubleTap: () => widget.cardKey.currentState!.toggleCard(),
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent
                      ],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 20,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: done,
                        child: const CircularProgressIndicator(),
                        builder: (
                          BuildContext context,
                          bool value,
                          Widget? child,
                        ) {
                          return value
                              ? lyrics['lyrics'] == ''
                                  ? emptyScreen(
                                      context,
                                      0,
                                      ':( ',
                                      100.0,
                                      AppLocalizations.of(context)!.lyrics,
                                      60.0,
                                      AppLocalizations.of(context)!
                                          .notAvailable,
                                      20.0,
                                      useWhite: true,
                                    )
                                  : SelectableText(
                                      lyrics['lyrics'].toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    )
                              : child!;
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Theme.of(context).cardColor.withOpacity(0.6),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: AppLocalizations.of(context)!.copy,
                      onPressed: () {
                        Feedback.forLongPress(context);
                        copyToClipboard(
                          context: context,
                          text: lyrics['lyrics'].toString(),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      color:
                          Theme.of(context).iconTheme.color!.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          front: StreamBuilder<QueueState>(
            stream: widget.audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;

              final bool enabled = Hive.box('settings')
                  .get('enableGesture', defaultValue: true) as bool;
              return GestureDetector(
                onTap: !enabled
                    ? null
                    : () {
                        tapped.value = true;
                        Future.delayed(const Duration(seconds: 2), () async {
                          tapped.value = false;
                        });
                      },
                onDoubleTapDown: (details) {
                  if (details.globalPosition.dx <= widget.width * 2 / 5) {
                    widget.audioHandler.customAction('rewind');
                    doubletapped.value = -1;
                    Future.delayed(const Duration(milliseconds: 500), () async {
                      doubletapped.value = 0;
                    });
                  }
                  if (details.globalPosition.dx > widget.width * 2 / 5 &&
                      details.globalPosition.dx < widget.width * 3 / 5) {
                    widget.cardKey.currentState!.toggleCard();
                  }
                  if (details.globalPosition.dx >= widget.width * 3 / 5) {
                    widget.audioHandler.customAction('fastForward');
                    doubletapped.value = 1;
                    Future.delayed(const Duration(milliseconds: 500), () async {
                      doubletapped.value = 0;
                    });
                  }
                },
                onDoubleTap: !enabled
                    ? null
                    : () {
                        Feedback.forLongPress(context);
                      },
                onHorizontalDragEnd: !enabled
                    ? null
                    : (DragEndDetails details) {
                        if ((details.primaryVelocity ?? 0) > 100) {
                          if (queueState.hasPrevious) {
                            widget.audioHandler.skipToPrevious();
                          }
                        }

                        if ((details.primaryVelocity ?? 0) < -100) {
                          if (queueState.hasNext) {
                            widget.audioHandler.skipToNext();
                          }
                        }
                      },
                onLongPress: !enabled
                    ? null
                    : () {
                        if (!widget.offline) {
                          Feedback.forLongPress(context);
                          AddToPlaylist()
                              .addToPlaylist(context, widget.mediaItem);
                        }
                      },
                onVerticalDragStart: !enabled
                    ? null
                    : (_) {
                        dragging.value = true;
                      },
                onVerticalDragEnd: !enabled
                    ? null
                    : (_) {
                        dragging.value = false;
                      },
                onVerticalDragUpdate: !enabled
                    ? null
                    : (DragUpdateDetails details) {
                        if (details.delta.dy != 0.0) {
                          double volume = widget.audioHandler.volume.value;
                          volume -= details.delta.dy / 150;
                          if (volume < 0) {
                            volume = 0;
                          }
                          if (volume > 1.0) {
                            volume = 1.0;
                          }
                          widget.audioHandler.setVolume(volume);
                        }
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          widget.mediaItem.artUri.toString().startsWith('file')
                              ? Image(
                                  fit: BoxFit.contain,
                                  width: widget.width * 0.85,
                                  gaplessPlayback: true,
                                  errorBuilder: (
                                    BuildContext context,
                                    Object exception,
                                    StackTrace? stackTrace,
                                  ) {
                                    return const Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/cover.jpg'),
                                    );
                                  },
                                  image: FileImage(
                                    File(
                                      widget.mediaItem.artUri!.toFilePath(),
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  errorWidget: (BuildContext context, _, __) =>
                                      const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                  placeholder: (BuildContext context, _) =>
                                      const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                  imageUrl: widget.mediaItem.artUri.toString(),
                                  width: widget.width * 0.85,
                                ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: dragging,
                      child: StreamBuilder<double>(
                        stream: widget.audioHandler.volume,
                        builder: (context, snapshot) {
                          final double volumeValue = snapshot.data ?? 1.0;
                          return Center(
                            child: SizedBox(
                              width: 60.0,
                              height: widget.width * 0.7,
                              child: Card(
                                color: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: RotatedBox(
                                          quarterTurns: -1,
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              thumbShape:
                                                  HiddenThumbComponentShape(),
                                              activeTrackColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                              inactiveTrackColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.4),
                                              trackShape:
                                                  const RoundedRectSliderTrackShape(),
                                            ),
                                            child: ExcludeSemantics(
                                              child: Slider(
                                                value: widget
                                                    .audioHandler.volume.value,
                                                onChanged: (_) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                      child: Icon(
                                        volumeValue == 0
                                            ? Icons.volume_off_rounded
                                            : volumeValue > 0.6
                                                ? Icons.volume_up_rounded
                                                : Icons.volume_down_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      builder: (
                        BuildContext context,
                        bool value,
                        Widget? child,
                      ) {
                        return Visibility(
                          visible: value,
                          child: child!,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: doubletapped,
                      child: const Icon(
                        Icons.forward_10_rounded,
                        size: 60.0,
                      ),
                      builder: (
                        BuildContext context,
                        int value,
                        Widget? child,
                      ) {
                        return Visibility(
                          visible: value != 0,
                          child: Card(
                            color: Colors.transparent,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox.expand(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: value == 1
                                        ? [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                            Colors.black.withOpacity(0.7),
                                          ]
                                        : [
                                            Colors.black.withOpacity(0.7),
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Visibility(
                                      visible: value == -1,
                                      child: const Icon(
                                        Icons.replay_10_rounded,
                                        size: 60.0,
                                      ),
                                    ),
                                    const SizedBox(),
                                    Visibility(
                                      visible: value == 1,
                                      child: child!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: tapped,
                      child: GestureDetector(
                        onTap: () {
                          tapped.value = false;
                        },
                        child: Card(
                          color: Colors.black26,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: IconButton(
                                      tooltip: AppLocalizations.of(context)!
                                          .songInfo,
                                      onPressed: () {
                                        final Map details =
                                            MediaItemConverter.mediaItemToMap(
                                          widget.mediaItem,
                                        );
                                        details['duration'] =
                                            '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                                        // style: Theme.of(context).textTheme.caption,
                                        if (widget.mediaItem.extras?['size'] !=
                                            null) {
                                          details.addEntries([
                                            MapEntry(
                                              'date_modified',
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                int.parse(
                                                      widget
                                                          .mediaItem
                                                          .extras![
                                                              'date_modified']
                                                          .toString(),
                                                    ) *
                                                    1000,
                                              ).toString().split('.').first,
                                            ),
                                            MapEntry(
                                              'size',
                                              '${((widget.mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                                            ),
                                          ]);
                                        }
                                        PopupDialog().showPopup(
                                          context: context,
                                          child: GradientCard(
                                            child: SingleChildScrollView(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: details.keys.map((e) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 10.0,
                                                    ),
                                                    child: SelectableText.rich(
                                                      TextSpan(
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                '${e[0].toUpperCase()}${e.substring(1)}\n'
                                                                    .replaceAll(
                                                              '_',
                                                              ' ',
                                                            ),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                              color: Theme.of(
                                                                context,
                                                              )
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .color,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: details[e]
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      showCursor: true,
                                                      cursorColor: Colors.black,
                                                      cursorRadius:
                                                          const Radius.circular(
                                                        5,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.info_rounded),
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: IconButton(
                                      tooltip: AppLocalizations.of(context)!
                                          .addToPlaylist,
                                      onPressed: () {
                                        AddToPlaylist().addToPlaylist(
                                          context,
                                          widget.mediaItem,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.playlist_add_rounded,
                                      ),
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      builder: (context, bool value, Widget? child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Visibility(visible: value, child: child!),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class NameNControls extends StatelessWidget {
  final MediaItem mediaItem;
  final bool offline;
  final double width;
  final double height;
  // final List<Color?>? gradientColor;
  final PanelController panelController;
  final AudioPlayerHandler audioHandler;

  const NameNControls({
    required this.width,
    required this.height,
    required this.mediaItem,
    // required this.gradientColor,
    required this.audioHandler,
    required this.panelController,
    this.offline = false,
  });

  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        AudioService.position,
        _bufferedPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    final double titleBoxHeight = height * 0.25;
    final double seekBoxHeight = height > 500 ? height * 0.15 : height * 0.2;
    final double controlBoxHeight = offline
        ? height > 500
            ? height * 0.2
            : height * 0.25
        : (height < 350
            ? height * 0.4
            : height > 500
                ? height * 0.2
                : height * 0.3);
    final double nowplayingBoxHeight = min(70, height * 0.15);
    // height > 500 ? height * 0.4 : height * 0.15;
    // final double minNowplayingBoxHeight = height * 0.15;
    final String gradientType = Hive.box('settings')
        .get('gradientType', defaultValue: 'halfDark')
        .toString();
    final List<String> artists = mediaItem.artist.toString().split(', ');
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Title and subtitle
              SizedBox(
                height: titleBoxHeight,
                child: PopupMenuButton<String>(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  offset: const Offset(1.0, 0.0),
                  onSelected: (String value) {
                    if (value == '0') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => SongsListPage(
                            listItem: {
                              'type': 'album',
                              'id': mediaItem.extras?['album_id'],
                              'title': mediaItem.album,
                              'image': mediaItem.artUri,
                            },
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => AlbumSearchPage(
                            query: value,
                            type: 'Artists',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (mediaItem.extras?['album_id'] != null)
                      PopupMenuItem<String>(
                        value: '0',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.album_rounded,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              AppLocalizations.of(context)!.viewAlbum,
                            ),
                          ],
                        ),
                      ),
                    if (mediaItem.artist != null)
                      ...artists.map(
                        (String artist) => PopupMenuItem<String>(
                          value: artist,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_rounded,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  '${AppLocalizations.of(context)!.viewArtist} ($artist)',
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: titleBoxHeight / 10,
                          ),

                          /// Title container
                          AnimatedText(
                            text: mediaItem.title
                                .split(' (')[0]
                                .split('|')[0]
                                .trim(),
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: TextStyle(
                              fontSize: titleBoxHeight / 2.75,
                              fontWeight: FontWeight.bold,
                              // color: Theme.of(context).accentColor,
                            ),
                          ),

                          SizedBox(
                            height: titleBoxHeight / 40,
                          ),

                          /// Subtitle container
                          AnimatedText(
                            text: ((mediaItem.album ?? '').isEmpty ||
                                    ((mediaItem.album ?? '') ==
                                        (mediaItem.artist ?? '')))
                                ? '${(mediaItem.artist ?? "").isEmpty ? "Unknown" : mediaItem.artist}'
                                : '${(mediaItem.artist ?? "").isEmpty ? "Unknown" : mediaItem.artist} • ${mediaItem.album}',
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: TextStyle(
                              fontSize: titleBoxHeight / 6.75,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// Seekbar starts from here
              SizedBox(
                height: seekBoxHeight,
                width: width * 0.95,
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          Duration.zero,
                          Duration.zero,
                          mediaItem.duration ?? Duration.zero,
                        );
                    return SeekBar(
                      // width: width,
                      // height: height,
                      duration: positionData.duration,
                      position: positionData.position,
                      bufferedPosition: positionData.bufferedPosition,
                      offline: offline,
                      onChangeEnd: (newPosition) {
                        audioHandler.seek(newPosition);
                      },
                      audioHandler: audioHandler,
                    );
                  },
                ),
              ),

              /// Final row starts from here
              SizedBox(
                height: controlBoxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6.0),
                              StreamBuilder<bool>(
                                stream: audioHandler.playbackState
                                    .map(
                                      (state) =>
                                          state.shuffleMode ==
                                          AudioServiceShuffleMode.all,
                                    )
                                    .distinct(),
                                builder: (context, snapshot) {
                                  final shuffleModeEnabled =
                                      snapshot.data ?? false;
                                  return IconButton(
                                    icon: shuffleModeEnabled
                                        ? const Icon(
                                            Icons.shuffle_rounded,
                                          )
                                        : Icon(
                                            Icons.shuffle_rounded,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                    tooltip:
                                        AppLocalizations.of(context)!.shuffle,
                                    onPressed: () async {
                                      final enable = !shuffleModeEnabled;
                                      await audioHandler.setShuffleMode(
                                        enable
                                            ? AudioServiceShuffleMode.all
                                            : AudioServiceShuffleMode.none,
                                      );
                                    },
                                  );
                                },
                              ),
                              if (!offline)
                                LikeButton(mediaItem: mediaItem, size: 25.0)
                            ],
                          ),
                          ControlButtons(
                            audioHandler,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6.0),
                              StreamBuilder<AudioServiceRepeatMode>(
                                stream: audioHandler.playbackState
                                    .map((state) => state.repeatMode)
                                    .distinct(),
                                builder: (context, snapshot) {
                                  final repeatMode = snapshot.data ??
                                      AudioServiceRepeatMode.none;
                                  const texts = ['None', 'All', 'One'];
                                  final icons = [
                                    Icon(
                                      Icons.repeat_rounded,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    const Icon(
                                      Icons.repeat_rounded,
                                    ),
                                    const Icon(
                                      Icons.repeat_one_rounded,
                                    ),
                                  ];
                                  const cycleModes = [
                                    AudioServiceRepeatMode.none,
                                    AudioServiceRepeatMode.all,
                                    AudioServiceRepeatMode.one,
                                  ];
                                  final index = cycleModes.indexOf(repeatMode);
                                  return IconButton(
                                    icon: icons[index],
                                    tooltip:
                                        'Repeat ${texts[(index + 1) % texts.length]}',
                                    onPressed: () async {
                                      await Hive.box('settings').put(
                                        'repeatMode',
                                        texts[(index + 1) % texts.length],
                                      );
                                      await audioHandler.setRepeatMode(
                                        cycleModes[
                                            (cycleModes.indexOf(repeatMode) +
                                                    1) %
                                                cycleModes.length],
                                      );
                                    },
                                  );
                                },
                              ),
                              if (!offline)
                                DownloadButton(
                                  size: 25.0,
                                  data: MediaItemConverter.mediaItemToMap(
                                    mediaItem,
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: nowplayingBoxHeight,
              ),
            ],
          ),

          // Up Next with blur background
          SlidingUpPanel(
            minHeight: nowplayingBoxHeight,
            maxHeight: 350,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            boxShadow: const [],
            color: ['fullLight', 'fullMix'].contains(gradientType)
                ? Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromRGBO(0, 0, 0, 0.05)
                    : const Color.fromRGBO(255, 255, 255, 0.05)
                : Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromRGBO(0, 0, 0, 0.5)
                    : const Color.fromRGBO(255, 255, 255, 0.5),
            // gradientColor![1]!.withOpacity(0.5),
            // useBlurForNowPlaying
            // ? Theme.of(context).brightness == Brightness.dark
            // Colors.black.withOpacity(0.2),
            // : Colors.white.withOpacity(0.7)
            // : Theme.of(context).brightness == Brightness.dark
            // ? Colors.black
            // : Colors.white,
            controller: panelController,
            panelBuilder: (ScrollController scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 8.0,
                    sigmaY: 8.0,
                  ),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        end: Alignment.topCenter,
                        begin: Alignment.center,
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ).createShader(
                        Rect.fromLTRB(
                          0,
                          0,
                          rect.width,
                          rect.height,
                        ),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: NowPlayingStream(
                      head: true,
                      headHeight: nowplayingBoxHeight,
                      audioHandler: audioHandler,
                      scrollController: scrollController,
                      panelController: panelController,
                    ),
                  ),
                ),
              );
            },
            header: GestureDetector(
              onTap: () {
                if (panelController.isPanelOpen) {
                  panelController.close();
                } else {
                  if (panelController.panelPosition > 0.9) {
                    panelController.close();
                  } else {
                    panelController.open();
                  }
                }
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                if (details.delta.dy > 0.0) {
                  panelController.animatePanelToPosition(0.0);
                }
              },
              child: Container(
                height: nowplayingBoxHeight,
                width: width,
                color: Colors.transparent,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Container(
                        width: 30,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.upNext,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
