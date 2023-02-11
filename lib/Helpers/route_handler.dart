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

import 'package:blackhole/APIs/api.dart';
import 'package:blackhole/APIs/spotify_api.dart';
import 'package:blackhole/Helpers/audio_query.dart';
import 'package:blackhole/Helpers/spotify_helper.dart';
import 'package:blackhole/Screens/Common/song_list.dart';
import 'package:blackhole/Screens/Player/audioplayer.dart';
import 'package:blackhole/Screens/Search/search.dart';
import 'package:blackhole/Screens/YouTube/youtube_playlist.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:blackhole/Services/youtube_services.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:on_audio_query/on_audio_query.dart';

// ignore: avoid_classes_with_only_static_members
class HandleRoute {
  static Route? handleRoute(String? url) {
    Logger.root.info('received route url: $url');
    if (url == null) return null;
    if (url.contains('saavn')) {
      final RegExpMatch? songResult =
          RegExp(r'.*saavn.com.*?\/(song)\/.*?\/(.*)').firstMatch('$url?');
      if (songResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => SaavnUrlHandler(
            token: songResult[2]!,
            type: songResult[1]!,
          ),
        );
      } else {
        final RegExpMatch? playlistResult = RegExp(
          r'.*saavn.com\/?s?\/(featured|playlist|album)\/.*\/(.*_)?[?/]',
        ).firstMatch('$url?');
        if (playlistResult != null) {
          return PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => SaavnUrlHandler(
              token: playlistResult[2]!,
              type: playlistResult[1]!,
            ),
          );
        }
      }
    } else if (url.contains('spotify')) {
      // TODO: Add support for spotify links
      Logger.root.info('received spotify link');
      final RegExpMatch? songResult =
          RegExp(r'.*spotify.com.*?\/(track)\/(.*?)[/?]').firstMatch('$url/');
      if (songResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => SpotifyUrlHandler(
            id: songResult[2]!,
            type: songResult[1]!,
          ),
        );
      }
    } else if (url.contains('youtube') || url.contains('youtu.be')) {
      // TODO: Add support for youtube links
      Logger.root.info('received youtube link');
      final RegExpMatch? videoId =
          RegExp(r'.*[\?\/](v|list)[=\/](.*?)[\/\?&#]').firstMatch('$url/');
      if (videoId != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => YtUrlHandler(
            id: videoId[2]!,
            type: videoId[1]!,
          ),
        );
      }
    } else {
      final RegExpMatch? fileResult =
          RegExp(r'\/[0-9]+\/([0-9]+)\/').firstMatch('$url/');
      if (fileResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => OfflinePlayHandler(
            id: fileResult[1]!,
          ),
        );
      }
    }
    return null;
  }
}

class SaavnUrlHandler extends StatelessWidget {
  final String token;
  final String type;
  const SaavnUrlHandler({super.key, required this.token, required this.type});

  @override
  Widget build(BuildContext context) {
    SaavnAPI().getSongFromToken(token, type).then((value) {
      if (type == 'song') {
        PlayerInvoke.init(
          songsList: value['songs'] as List,
          index: 0,
          isOffline: false,
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const PlayScreen(),
          ),
        );
      }
      if (type == 'album' || type == 'playlist' || type == 'featured') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => SongsListPage(
              listItem: value,
            ),
          ),
        );
      }
    });
    return Container();
  }
}

class SpotifyUrlHandler extends StatelessWidget {
  final String id;
  final String type;
  const SpotifyUrlHandler({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'track') {
      callSpotifyFunction((String accessToken) {
        SpotifyApi().getTrackDetails(accessToken, id).then((value) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => SearchPage(
                query: (value['artists'] != null &&
                        (value['artists'] as List).isNotEmpty)
                    ? '${value["name"]} by ${value["artists"][0]["name"]}'
                    : value['name'].toString(),
              ),
            ),
          );
        });
      });
    }
    return Container();
  }
}

class YtUrlHandler extends StatelessWidget {
  final String id;
  final String type;
  const YtUrlHandler({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'v') {
      YouTubeServices().formatVideoFromId(id: id).then((Map? response) async {
        if (response != null) {
          PlayerInvoke.init(
            songsList: [response],
            index: 0,
            isOffline: false,
            recommend: false,
          );
        }
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const PlayScreen(),
          ),
        );
      });
    } else if (type == 'list') {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlaylist(
              playlistId: id,
              // playlistImage: '',
              // playlistName: '',
              // playlistSubtitle: '',
              // playlistSecondarySubtitle: '',
            ),
          ),
        );
      });
    }
    return const SizedBox();
  }
}

class OfflinePlayHandler extends StatelessWidget {
  final String id;
  const OfflinePlayHandler({super.key, required this.id});

  Future<List> playOfflineSong(String id) async {
    final OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
    await offlineAudioQuery.requestPermission();

    final List<SongModel> songs = await offlineAudioQuery.getSongs();
    final int index = songs.indexWhere((i) => i.id.toString() == id);

    return [index, songs];
  }

  @override
  Widget build(BuildContext context) {
    playOfflineSong(id).then((value) {
      PlayerInvoke.init(
        songsList: value[1] as List<SongModel>,
        index: value[0] as int,
        isOffline: true,
        recommend: false,
      );
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => const PlayScreen(),
        ),
      );
    });
    return const SizedBox();
  }
}
