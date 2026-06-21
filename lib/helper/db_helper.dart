import 'package:craft_discount_liquors/data/datasource/local/cache_response.dart';
import 'package:craft_discount_liquors/di_container.dart';

class DbHelper {
  static Future<void> insertOrUpdate({
    required String id,
    required CacheResponseCompanion data,
  }) async {
    final response = await database.getCacheResponseById(id);

    if (response != null) {
      await database.updateCacheResponse(id, data);
    } else {
      await database.insertCacheResponse(data);
    }
  }
}
