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

import 'dart:math';

import 'package:logging/logging.dart';

int findBestMatch(
  List songs,
  Map matchSong, {
  bool shouldMatch = true,
  double breakThreshold = 0.9,
}) {
  int bestMatchIndex = -1;
  MatchResponse bestMatchResponse = MatchResponse(matched: false, accuracy: 0);
  for (int i = 0; i < songs.length; i++) {
    final res = matchSongs(
      title: songs[i]['title'].toString(),
      artist: songs[i]['artist'].toString(),
      title2: matchSong['title'].toString(),
      artist2: matchSong['artist'].toString(),
    );
    if ((res.matched || !shouldMatch) &&
        res.accuracy > bestMatchResponse.accuracy) {
      bestMatchResponse = res;
      bestMatchIndex = i;
      if (res.accuracy >= breakThreshold) {
        break;
      }
    }
  }
  return bestMatchIndex;
}

MatchResponse matchSongs({
  required String title,
  required String artist,
  required String title2,
  required String artist2,
  double artistAccuracy = 0.85,
  double titleAccuracy = 0.7,
  bool allowTitleToArtistMatch = true,
}) {
  Logger.root.info('Matching $title by $artist with $title2 by $artist2');
  final names1 = artist.replaceAll('&', ',').replaceAll('-', ',').split(',');
  final names2 = artist2.replaceAll('&', ',').replaceAll('-', ',').split(',');
  MatchResponse artistMatchResponse =
      MatchResponse(matched: false, accuracy: 0);
  MatchResponse titleMatchResponse = MatchResponse(matched: false, accuracy: 0);

  // Check if at least one artist name matches
  for (final String name1 in names1) {
    for (final String name2 in names2) {
      artistMatchResponse = flexibleMatch(
        string1: name1,
        string2: name2,
        accuracy: artistAccuracy,
      );

      if (artistMatchResponse.matched) {
        break;
      } else if (allowTitleToArtistMatch) {
        if (title2.contains(name1) || title.contains(name2)) {
          artistMatchResponse = MatchResponse(matched: true, accuracy: 0.8);
          break;
        }
      }
    }
    if (artistMatchResponse.matched) {
      break;
    }
  }

  titleMatchResponse = flexibleMatch(
    string1: title,
    string2: title2,
    wordMatch: true,
    accuracy: titleAccuracy,
  );

  Logger.root.info(
    'TitleMatched: ${titleMatchResponse.matched} - ${titleMatchResponse.accuracy}, ArtistMatched: ${artistMatchResponse.matched} - ${artistMatchResponse.accuracy}',
  );

  return MatchResponse(
    matched: titleMatchResponse.matched && artistMatchResponse.matched,
    accuracy: (titleMatchResponse.accuracy + artistMatchResponse.accuracy) / 2,
  );
}

MatchResponse flexibleMatch({
  required String string1,
  required String string2,
  double accuracy = 0.7,
  bool wordMatch = false,
}) {
  final text1 = string1.toLowerCase().trim();
  final text2 = string2.toLowerCase().trim();
  if (text1 == text2) {
    return MatchResponse(matched: true, accuracy: 1);
  } else if (text1.contains(text2) || text2.contains(text1)) {
    return MatchResponse(
      matched: true,
      accuracy: 0.9 -
          0.1 *
              (1 -
                  (min(text1.length, text2.length) /
                      max(text1.length, text2.length))),
    );
  } else if (accuracy < 1) {
    final MatchResponse matchResponse = accuracyCheck(
      text1: text1,
      text2: text2,
      wordMatch: wordMatch,
      accuracy: accuracy,
    );
    if (matchResponse.matched) {
      return MatchResponse(
        matched: matchResponse.matched,
        accuracy: 0.8 - 0.1 * (1 - matchResponse.accuracy),
      );
    } else if (text1.contains('(') || text2.contains('(')) {
      final res = accuracyCheck(
        text1: text1.split('(')[0].trim(),
        text2: text2.split('(')[0].trim(),
        wordMatch: wordMatch,
        accuracy: accuracy,
      );
      return MatchResponse(
        matched: res.matched,
        accuracy: 0.7 - 0.1 * (1 - res.accuracy),
      );
    }
  }

  return MatchResponse(
    matched: false,
    accuracy: 0,
  );
}

MatchResponse accuracyCheck({
  required String text1,
  required String text2,
  required bool wordMatch,
  required double accuracy,
}) {
  int count = 0;
  final list1 = wordMatch ? text1.split(' ') : text1.split('');
  final list2 = wordMatch ? text2.split(' ') : text2.split('');
  final minLength = list1.length > list2.length ? list2.length : list1.length;

  for (int i = 0; i < minLength; i++) {
    if (list1[i] == list2[i]) {
      count++;
    } else {
      break;
    }
  }
  final percentage = count / minLength;
  if (percentage >= accuracy) {
    return MatchResponse(matched: true, accuracy: percentage);
  }
  return MatchResponse(matched: false, accuracy: 0);
}

class MatchResponse {
  final bool matched;
  final double accuracy;
  MatchResponse({
    required this.matched,
    required this.accuracy,
  });
}
