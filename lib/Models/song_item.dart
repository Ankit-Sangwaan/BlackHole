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

import 'dart:convert';

class SongItem {
  final String id;
  final String album;
  final String albumId;
  final List<String> artists;
  final List<Map<String, String>>? artistIds;
  final String? albumArtist;
  final Duration duration;
  final String genre;
  final bool hasLyrics;
  final String image;
  final List allImages;
  final String language;
  final String releaseDate;
  final String subtitle;
  final String title;
  final String url;
  final List<String> allUrls;
  final int year;
  final int quality;
  final String permaUrl;
  final int expireAt;
  final bool isYt;
  final String lyrics;
  final int? trackNumber;
  final int? discNumber;
  final bool isOffline;
  final bool addedByAutoplay;
  final bool kbps320;

  SongItem({
    required this.id,
    required this.album,
    required this.albumId,
    required this.artists,
    this.artistIds,
    this.albumArtist,
    required this.duration,
    required this.genre,
    this.hasLyrics = false,
    required this.image,
    required this.allImages,
    required this.language,
    required this.releaseDate,
    required this.subtitle,
    required this.title,
    required this.url,
    required this.allUrls,
    required this.year,
    required this.quality,
    required this.permaUrl,
    required this.expireAt,
    required this.isYt,
    required this.lyrics,
    this.trackNumber,
    this.discNumber,
    this.isOffline = false,
    this.addedByAutoplay = false,
    this.kbps320 = false,
  });

  factory SongItem.fromMap(Map<String, dynamic> map) {
    return SongItem(
      id: map['id'].toString(),
      album: map['album'].toString(),
      artists: map['artists'] as List<String>,
      duration: Duration(seconds: int.parse(map['duration'].toString())),
      genre: map['genre'].toString(),
      image: map['image'].toString(),
      allImages: map['allImages'] as List,
      language: map['language'].toString(),
      releaseDate: map['releaseDate'].toString(),
      subtitle: map['subtitle'].toString(),
      title: map['title'].toString(),
      url: map['url'].toString(),
      allUrls: map['allUrls'] as List<String>,
      year: int.parse(map['year'].toString()),
      quality: int.parse(map['quality'].toString()),
      permaUrl: map['permaUrl'].toString(),
      expireAt: int.parse(map['expireAt']?.toString() ?? '0'),
      lyrics: map['lyrics']?.toString() ?? '',
      trackNumber: int.parse(map['trackNumber']?.toString() ?? '0'),
      discNumber: int.parse(map['discNumber']?.toString() ?? '0'),
      isOffline: map['isOffline'] as bool,
      addedByAutoplay: map['addedByAutoplay'] as bool,
      albumId: map['albumId'].toString(),
      artistIds: map['artistIds'] as List<Map<String, String>>?,
      isYt: map['isYt'] as bool,
      kbps320: map['320kbps'] as bool,
      albumArtist: map['albumArtist']?.toString(),
      hasLyrics: map['hasLyrics'] as bool? ?? false,
    );
  }

  factory SongItem.fromJson(String source) =>
      SongItem.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'album': album,
      'artists': artists,
      'duration': duration.inSeconds,
      'genre': genre,
      'image': image,
      'allImages': allImages,
      'language': language,
      'releaseDate': releaseDate,
      'subtitle': subtitle,
      'title': title,
      'url': url,
      'allUrls': allUrls,
      'year': year,
      'quality': quality,
      'permaUrl': permaUrl,
      'expireAt': expireAt,
      'lyrics': lyrics,
      'trackNumber': trackNumber,
      'discNumber': discNumber,
      'isOffline': isOffline,
      'addedByAutoplay': addedByAutoplay,
      'albumId': albumId,
      'artistIds': artistIds,
      'isYt': isYt,
      '320kbps': kbps320,
      'albumArtist': albumArtist,
      'hasLyrics': hasLyrics,
    };
  }

  String toJson() => json.encode(toMap());
}
