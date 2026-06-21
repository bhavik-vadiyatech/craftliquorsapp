import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/common/models/product_model.dart';
import 'package:craft_discount_liquors/common/reposotories/product_repo.dart';
import 'package:craft_discount_liquors/data/datasource/local/cache_response.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_product_model.dart';
import 'package:craft_discount_liquors/features/category/domain/reposotories/category_repo.dart';
import 'package:craft_discount_liquors/features/search/domain/reposotories/search_repo.dart';
import 'package:craft_discount_liquors/helper/api_checker_helper.dart';
import 'package:craft_discount_liquors/helper/data_sync_helper.dart';

import '../../../utill/app_constants.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepo categoryRepo;
  final ProductRepo productRepo;
  final SearchRepo searchRepo;

  CategoryProvider({
    required this.categoryRepo,
    required this.productRepo,
    required this.searchRepo,
  });

  int _selectedCategoryIndex = -1;
  int _categoryIndex = 0;
  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList = [];
  CategoryProductModel? _categoryProductList;
  final List<Product> _categoryAllProductList = [];
  CategoryModel? _categoryModel;
  int _selectCategory = -1;

  int get categoryIndex => _categoryIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  CategoryProductModel? get categoryProductList => _categoryProductList;
  CategoryModel? get categoryModel => _categoryModel;
  int get selectCategory => _selectCategory;

  Future<List<CategoryModel>?> getCategoryList(
    BuildContext context,
    bool reload, {
    DataSourceEnum source = DataSourceEnum.local,
  }) async {
    if (_categoryList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => categoryRepo.getCategoryList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            categoryRepo.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          _categoryList = [];
          data.forEach(
            (category) => _categoryList!.add(CategoryModel.fromJson(category)),
          );
          _selectedCategoryIndex = -1;
          _categoryIndex = 0;
          notifyListeners();
        },
      );
    }

    return _categoryList;
  }

  void getCategory(int? id, BuildContext context) async {
    if (_categoryList == null) {
      await getCategoryList(context, true);
      _categoryModel = _categoryList!.firstWhere(
        (category) => category.id == id,
      );
      notifyListeners();
    } else {
      try {
        _categoryModel = _categoryList!.firstWhere(
          (category) => category.id == id,
        );
      } catch (e) {
        debugPrint('error : $e');
      }
    }
  }

  void getSubCategoryList(BuildContext context, String categoryID) async {
    _subCategoryList = null;

    ApiResponseModel apiResponse = await categoryRepo.getSubCategoryList(
      categoryID,
    );
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _subCategoryList = [];
      apiResponse.response!.data.forEach(
        (category) => _subCategoryList!.add(CategoryModel.fromJson(category)),
      );
      getCategoryProductList(categoryID, 1);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void getCategoryProductList(
    String categoryID,
    int offset, {
    double? priceLow,
    double? priceHigh,
    String? sortBy,
    int? rating,
  }) async {
    ApiResponseModel apiResponse = await productRepo
        .getBrandOrCategoryProductList(
          categoryID,
          offset,
          priceLow: priceLow,
          priceHigh: priceHigh,
          sortBy: sortBy,
          rating: rating,
        );
    if (apiResponse.response?.statusCode == 200) {
      _categoryProductList = CategoryProductModel.fromJson(
        apiResponse.response?.data,
      );
      _categoryAllProductList.addAll(_categoryProductList?.products ?? []);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void updateSelectCategory(int index) {
    _selectCategory = index;
    notifyListeners();
  }

  void onChangeSelectIndex(int selectedIndex, {bool notify = true}) {
    _selectedCategoryIndex = selectedIndex;
    if (notify) {
      notifyListeners();
    }
  }

  void onChangeCategoryIndex(int selectedIndex, {bool notify = true}) {
    _categoryIndex = selectedIndex;
    if (notify) {
      notifyListeners();
    }
  }

  CategoryProductModel? _subCategoryProductList;
  bool? _hasData;
  double _maxValue = 0;
  double? _filterPriceLow;
  double? _filterPriceHigh;
  String? _sortBy;
  int? _rating;
  int? _selectedRatingIndex;
  int? _selectedPriceIndex;
  String? _selectedSortBy;

  int? get selectedRatingIndex => _selectedRatingIndex;
  int? get selectedPriceIndex => _selectedPriceIndex;
  String? get selectedSortBy => _selectedSortBy;
  double get maxValue => _maxValue;
  double? get filterPriceLow => _filterPriceLow;
  double? get filterPriceHigh => _filterPriceHigh;

  bool get hasActiveFilters =>
      _filterPriceLow != null ||
      _filterPriceHigh != null ||
      _sortBy != null ||
      _rating != null;

  void setRatingIndex(int? value) {
    _selectedRatingIndex = value;
    notifyListeners();
  }

  void setPriceIndex(int? value) {
    _selectedPriceIndex = value;
    notifyListeners();
  }

  void setPriceRange(double? low, double? high) {
    _filterPriceLow = low;
    _filterPriceHigh = high;
  }

  void setSortBy(String? value) {
    _selectedSortBy = value;
    notifyListeners();
  }

  CategoryProductModel? get subCategoryProductList => _subCategoryProductList;
  List<String?> _allSortBy = [];
  List<String?> get allSortBy => _allSortBy;
  List<String?> _allFilterBy = [];
  List<String?> get allFilterBy => _allFilterBy;
  bool? get hasData => _hasData;
  int _sortByIndex = 0;
  int get sortByIndex => _sortByIndex;
  int _filterByIndex = 0;
  int get filterByIndex => _filterByIndex;

  void setSortByIndex(int index) {
    _sortByIndex = index;
    notifyListeners();
  }

  void setFilterByIndex(int index) {
    _filterByIndex = index;
    notifyListeners();
  }

  void clearCategoryProducts() {
    _subCategoryProductList = null;
    _hasData = true;
    notifyListeners();
  }

  void clearCategoryFilter() {
    _filterPriceLow = null;
    _filterPriceHigh = null;
    _sortBy = null;
    _rating = null;
    _selectedRatingIndex = null;
    _selectedPriceIndex = null;
    _selectedSortBy = null;
  }

  void _updateFilterStateFromModel() {
    final model = _subCategoryProductList;
    if (model == null) return;

    _filterPriceLow = model.filterPriceLow;
    _filterPriceHigh = model.filterPriceHigh;
    _selectedSortBy = _sortBy != null ? model.sortBy : null;
    _selectedRatingIndex = model.rating != null ? 5 - model.rating! : null;

    _selectedPriceIndex = null;
    if (model.filterPriceLow != null && model.filterPriceHigh != null) {
      for (int i = 0; i < AppConstants.priceRanges.length; i++) {
        if (model.filterPriceLow == AppConstants.priceRanges[i][0] &&
            model.filterPriceHigh == AppConstants.priceRanges[i][1]) {
          _selectedPriceIndex = i;
          break;
        }
      }
    }
  }

  void initCategoryProductList(
    String id,
    int offset, {
    double? priceLow,
    double? priceHigh,
    String? sortBy,
    int? rating,
  }) async {
    if (offset == 1) {
      _subCategoryProductList = null;
      _hasData = true;
      notifyListeners();
    } else {
      _hasData = true;
    }

    _filterPriceLow = priceLow;
    _filterPriceHigh = priceHigh;
    _sortBy = sortBy;
    _rating = rating;

    ApiResponseModel apiResponse = await productRepo
        .getBrandOrCategoryProductList(
          id,
          offset,
          priceLow: _filterPriceLow,
          priceHigh: _filterPriceHigh,
          sortBy: _sortBy,
          rating: _rating,
        );
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _subCategoryProductList = CategoryProductModel.fromJson(
          apiResponse.response!.data,
        );
      } else {
        _subCategoryProductList?.products?.addAll(
          CategoryProductModel.fromJson(apiResponse.response!.data).products!,
        );
        _subCategoryProductList?.offset = CategoryProductModel.fromJson(
          apiResponse.response!.data,
        ).offset;
        _subCategoryProductList?.totalSize = CategoryProductModel.fromJson(
          apiResponse.response!.data,
        ).totalSize;
      }

      _updateFilterStateFromModel();

      _hasData = (_subCategoryProductList?.products?.length ?? 0) > 1;
      List<Product> products = [];
      products.addAll(_subCategoryProductList?.products ?? []);
      List<double> prices = [];
      for (var product in products) {
        prices.add(double.parse(product.price.toString()));
      }
      prices.sort();
      if ((subCategoryProductList?.products ?? []).isNotEmpty) {
        _maxValue = prices[prices.length - 1];
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void initializeAllSortBy(BuildContext context) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo.getAllSortByList();
    }
    if (_allFilterBy.isEmpty) {
      _allFilterBy = [];
      _allFilterBy = searchRepo.getAllFilterByList();
    }
  }
}
