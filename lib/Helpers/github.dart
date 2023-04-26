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

import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

class GitHub {
  static String repo = 'Sangwan5688/BlackHole';
  static String baseUrl = 'api.github.com';
  static Map<String, String> headers = {};
  static Map<String, String> endpoints = {
    'repo': '/repos',
    'releases': '/releases',
  };
  Map releasesData = {};

  static final GitHub _singleton = GitHub._internal();
  factory GitHub() {
    return _singleton;
  }
  GitHub._internal();

  static Future<Response> getResponse() async {
    final Uri url = Uri.https(
      baseUrl,
      '${endpoints["repo"]}/$repo${endpoints["releases"]}',
    );

    return get(url, headers: headers).onError((error, stackTrace) {
      return Response(
        {
          'status': false,
          'message': error.toString(),
        }.toString(),
        404,
      );
    });
  }

  static Future<Map> fetchReleases() async {
    final res = await getResponse();
    if (res.statusCode == 200) {
      final resp = json.decode(res.body);
      if (resp is List) {
        return resp[0] as Map;
      } else if (resp is Map) {
        Logger.root.severe('Failed to fetch releases', resp['message']);
      }
    } else {
      Logger.root.severe('Failed to fetch releases', res.body);
    }
    return {};
  }

  static Future<String> getLatestVersion() async {
    Logger.root.info('Checking for update');
    final Map latestRelease = await fetchReleases();
    Logger.root.info(
      'Latest release: ${(latestRelease["tag_name"] as String?) ?? "v0.0.0"}',
    );
    return ((latestRelease['tag_name'] as String?) ?? 'v0.0.0')
        .replaceAll('v', '');
  }
}
