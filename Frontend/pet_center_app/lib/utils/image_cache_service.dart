import 'dart:collection';
import 'dart:typed_data';

class ImageCacheService {
  ImageCacheService._();
  static final ImageCacheService instance = ImageCacheService._();

  static const int _maxEntries = 256;
  static const int _maxBytes = 100 * 1024 * 1024;

  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();
  int _totalBytes = 0;

  Uint8List? get(String hash) {
    final bytes = _cache.remove(hash);
    if (bytes == null) return null;
    _cache[hash] = bytes;
    return bytes;
  }

  void put(String hash, Uint8List bytes) {
    if (_cache.containsKey(hash)) {
      _totalBytes -= _cache[hash]!.lengthInBytes;
      _cache.remove(hash);
    }

    _cache[hash] = bytes;
    _totalBytes += bytes.lengthInBytes;

    _evict();
  }

  void invalidate(String hash) {
    final bytes = _cache.remove(hash);
    if (bytes != null) _totalBytes -= bytes.lengthInBytes;
  }

  void clear() {
    _cache.clear();
    _totalBytes = 0;
  }

  void _evict() {
    while (_cache.isNotEmpty &&
        (_cache.length > _maxEntries || _totalBytes > _maxBytes)) {
      final oldest = _cache.keys.first;
      _totalBytes -= _cache[oldest]!.lengthInBytes;
      _cache.remove(oldest);
    }
  }
}
