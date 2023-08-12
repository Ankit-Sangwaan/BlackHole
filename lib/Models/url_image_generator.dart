import 'package:blackhole/Models/image_quality.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UrlImageGetter {
  final List<String?> _imageUrls;
  final _enableImageOptimization = Hive.box('settings').get(
    'enableImageOptimization',
    defaultValue: false,
  ) as bool;

  UrlImageGetter(this._imageUrls);

  String get lowQuality => getImageUrl(
        quality: ImageQuality.low,
      );
  String get mediumQuality => getImageUrl(
        quality: ImageQuality.medium,
      );
  String get highQuality => getImageUrl();

  String getImageUrl({
    ImageQuality? quality = ImageQuality.high,
  }) {
    if (_imageUrls.isEmpty) return '';
    final length = _imageUrls.length;

    ImageQuality? imageQuality = quality;

    if (_enableImageOptimization == false) {
      switch (imageQuality) {
        case ImageQuality.low:
          imageQuality = ImageQuality.medium;
          break;
        case ImageQuality.medium:
          imageQuality = ImageQuality.high;
          break;
        default:
          imageQuality = ImageQuality.high;
      }
    }

    switch (imageQuality) {
      case ImageQuality.high:
        return length == 1
            ? (_imageUrls.first
                    ?.trim()
                    .replaceAll('http:', 'https:')
                    .replaceAll('50x50', '500x500')
                    .replaceAll('150x150', '500x500') ??
                '')
            : _imageUrls.last ?? '';
      case ImageQuality.medium:
        return length == 1
            ? _imageUrls.first
                    ?.trim()
                    .replaceAll('http:', 'https:')
                    .replaceAll('50x50', '150x150')
                    .replaceAll('500x500', '150x150') ??
                ''
            : _imageUrls[length ~/ 2] ?? '';
      case ImageQuality.low:
        return length == 1
            ? _imageUrls.first
                    ?.trim()
                    .replaceAll('http:', 'https:')
                    .replaceAll('150x150', '50x50')
                    .replaceAll('500x500', '50x50') ??
                ''
            : _imageUrls.first!;
      default:
        return length == 1
            ? _imageUrls.first
                    ?.trim()
                    .replaceAll('http:', 'https:')
                    .replaceAll('50x50', '500x500')
                    .replaceAll('150x150', '500x500') ??
                ''
            : _imageUrls.last!;
    }
  }
}
