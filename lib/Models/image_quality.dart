enum ImageQuality {
  low._('low'),
  medium._('medium'),
  high._('high');

  final String _quality;

  const ImageQuality._(this._quality);

  @override
  String toString() => _quality;
}
