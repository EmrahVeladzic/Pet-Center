import 'package:hive/hive.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

class CacheManager {
  static const String cacheName = 'cache';

  static String _key(String entityId, CacheEntityType type) {
    return 'user:${self?.id}|type:${type.name}|entity:$entityId';
  }

  static Future<Box> _box() => Hive.openBox(cacheName);

  static Future<bool> read(String entityId, CacheEntityType type) async {
    final box = await _box();
    return box.get(_key(entityId, type), defaultValue: false);
  }

  static Future<void> write(String entityId, CacheEntityType type) async {
    final box = await _box();

    final key = _key(entityId, type);

    if (!await CacheManager.read(entityId, type)) {
      await box.put(key, true);
    }
  }

  static Future<void> clear() async {
    final box = await _box();

    final prefix = 'user:${self?.id}|';

    final keysToDelete = box.keys
        .where((k) => k.toString().startsWith(prefix))
        .toList();

    await box.deleteAll(keysToDelete);
  }

  static Future<Set<String>> getAll(CacheEntityType type) async {
    final box = await _box();

    final prefix = 'user:${self?.id}|type:${type.name}|';

    return box.keys.where((k) => k.toString().startsWith(prefix)).map((k) {
      final key = k.toString();

      final start = key.indexOf('entity:') + 'entity:'.length;
      return key.substring(start);
    }).toSet();
  }
}
