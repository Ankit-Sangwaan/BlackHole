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

import 'package:app_links/app_links.dart';
import 'package:blackhole/APIs/spotify_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String?> retriveAccessToken() async {
  String? accessToken = Hive.box('settings')
      .get('spotifyAccessToken', defaultValue: null)
      ?.toString();
  String? refreshToken = Hive.box('settings')
      .get('spotifyRefreshToken', defaultValue: null)
      ?.toString();
  final double expiredAt = Hive.box('settings')
      .get('spotifyTokenExpireAt', defaultValue: 0.0) as double;

  if (accessToken == null || refreshToken == null) {
    return null;
  } else {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    if ((currentTime + 60) >= expiredAt) {
      final List<String> data =
          await SpotifyApi().getAccessToken(refreshToken: refreshToken);
      if (data.isNotEmpty) {
        Hive.box('settings').put('spotifySigned', true);
        accessToken = data[0];
        Hive.box('settings').put('spotifyAccessToken', data[0]);
        if (data[1] != 'null') {
          refreshToken = data[1];
          Hive.box('settings').put('spotifyRefreshToken', data[1]);
        }
        Hive.box('settings')
            .put('spotifyTokenExpireAt', currentTime + double.parse(data[2]));
      }
    }
    return accessToken;
  }
}

Future<void> callSpotifyFunction(Function(String accessToken)? function) async {
  final String? accessToken = await retriveAccessToken();
  if (accessToken != null && function != null) {
    return await function.call(accessToken);
  }
  if (accessToken == null) {
    launchUrl(
      Uri.parse(
        SpotifyApi().requestAuthorization(),
      ),
      mode: LaunchMode.externalApplication,
    );
    AppLinks(
      onAppLink: (Uri uri, String link) async {
        closeInAppWebView();
        if (link.contains('code=')) {
          final code = link.split('code=')[1];
          Hive.box('settings').put('spotifyAppCode', code);
          final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
          final List<String> data =
              await SpotifyApi().getAccessToken(code: code);
          if (data.isNotEmpty) {
            Hive.box('settings').put('spotifyAccessToken', data[0]);
            Hive.box('settings').put('spotifyRefreshToken', data[1]);
            Hive.box('settings').put(
              'spotifyTokenExpireAt',
              currentTime + int.parse(data[2]),
            );
            if (function != null) {
              return await function.call(data[0]);
            }
          }
        }
      },
    );
  }
}
