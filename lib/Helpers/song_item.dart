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

  factory SongItem.fromJson(Map<String, dynamic> json) {
    return SongItem(
      id: json['id'].toString(),
      album: json['album'].toString(),
      artists: json['artists'] as List<String>,
      duration: Duration(seconds: int.parse(json['duration'].toString())),
      genre: json['genre'].toString(),
      image: json['image'].toString(),
      allImages: json['images'] as List,
      language: json['language'].toString(),
      releaseDate: json['releaseDate'].toString(),
      subtitle: json['subtitle'].toString(),
      title: json['title'].toString(),
      url: json['url'].toString(),
      allUrls: json['allUrls'] as List<String>,
      year: int.parse(json['year'].toString()),
      quality: int.parse(json['quality'].toString()),
      permaUrl: json['permaUrl'].toString(),
      expireAt: int.parse(json['expireAt']?.toString() ?? '0'),
      lyrics: json['lyrics']?.toString() ?? '',
      trackNumber: int.parse(json['track']?.toString() ?? '0'),
      discNumber: int.parse(json['discNumber']?.toString() ?? '0'),
      isOffline: json['isOffline'] as bool,
      addedByAutoplay: json['addedByAutoplay'] as bool,
      albumId: json['albumId'].toString(),
      artistIds: json['artistIds'] as List<Map<String, String>>?,
      isYt: json['isYt'] as bool,
      kbps320: json['320kbps'] as bool,
      albumArtist: json['albumArtist']?.toString(),
      hasLyrics: json['hasLyrics'] as bool? ?? false,
    );
  }
}
