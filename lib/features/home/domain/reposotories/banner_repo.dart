import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/common/reposotories/data_sync_repo.dart';
import 'package:craft_discount_liquors/data/datasource/remote/exception/api_error_handler.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';

class BannerRepo extends DataSyncRepo {
  BannerRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getBannerList<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.bannerUri, source);
  }

  Future<ApiResponseModel> getProductDetails(String productID) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.productDetailsUri}$productID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
