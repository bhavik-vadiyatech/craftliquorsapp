import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/common/models/product_model.dart';
import 'package:craft_discount_liquors/features/search/domain/reposotories/search_repo.dart';
import 'package:craft_discount_liquors/helper/api_checker_helper.dart';

import '../../../utill/app_constants.dart';

class SearchProvider with ChangeNotifier {
  final SearchRepo? searchRepo;

  SearchProvider({required this.searchRepo});

  String? _selectedFilter;
  double? _lowerValue;
  double? _upperValue;
  List<String?> _historyList = [];
  int? _selectedRatingIndex;
  int? _selectedPriceIndex;
  String? _selectedSortBy;
  List<int> _selectedCategories = [];

  double? _userPriceLow;
  double? _userPriceHigh;
  String? _userSortBy;
  int? _userRating;
  List<int>? _userCategories;

  String? get selectedFilter => _selectedFilter;
  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;
  int? get selectedRatingIndex => _selectedRatingIndex;
  int? get selectedPriceIndex => _selectedPriceIndex;
  String? get selectedSortBy => _selectedSortBy;
  List<int> get selectedCategories => _selectedCategories;

  bool get hasActiveFilters =>
      _userPriceLow != null ||
      _userPriceHigh != null ||
      _userSortBy != null ||
      _userRating != null ||
      (_userCategories != null && _userCategories!.isNotEmpty);

  bool _isClear = true;
  String _searchText = '';
  bool _isSearch = true;

  bool get isClear => _isClear;
  bool get isSearch => _isSearch;

  String get searchText => _searchText;
  List<String?> get historyList => _historyList;

  final List<Product> _categoryProductList = [];
  List<Product> get categoryProductList => _categoryProductList;

  List<String?> _allSortBy = [];

  List<String?> get allSortBy => _allSortBy;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  int _searchLength = 0;
  int get searchLength => _searchLength;

  void onChangeSearchStatus() {
    _isSearch = !_isSearch;
    notifyListeners();
  }

  void setSearchValue(String searchText) {
    _searchController = TextEditingController(text: searchText);
    _searchLength = searchText.length;
    notifyListeners();
  }

  void setFilterValue(String? value, {bool isUpdate = true}) {
    _selectedFilter = value;

    if (isUpdate) {
      notifyListeners();
    }
  }

  void initializeAllSortBy({bool notify = true}) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo!.getAllSortByList();
    }
    _selectedFilter = null;
    if (notify) {
      notifyListeners();
    }
  }

  void setLowerAndUpperValue(
    double? lower,
    double? upper, {
    bool isUpdate = true,
  }) {
    _lowerValue = lower;
    _upperValue = upper;

    if (isUpdate) {
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedRatingIndex = null;
    _selectedPriceIndex = null;
    _selectedSortBy = null;
    _selectedCategories = [];
    _lowerValue = null;
    _upperValue = null;
    _userPriceLow = null;
    _userPriceHigh = null;
    _userSortBy = null;
    _userRating = null;
    _userCategories = null;
  }

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void cleanSearchProduct() {
    _isClear = true;
    _searchText = '';
    notifyListeners();
  }

  ProductModel? _searchProductModel;
  ProductModel? get searchProductModel => _searchProductModel;

  Future<void> getSearchProduct({
    required int offset,
    required String query,
    double? priceLow,
    double? priceHigh,
    String? filterType,
    int? rating,
    List<int>? categories,
    bool isUpdate = false,
  }) async {
    if (query.isNotEmpty) {
      _searchText = query;
    }

    if (offset == 1) {
      _searchProductModel?.products = null;
      _userPriceLow = priceLow;
      _userPriceHigh = priceHigh;
      _userSortBy = filterType;
      _userRating = rating;
      _userCategories = categories;

      if (isUpdate) {
        notifyListeners();
      }
    }

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      name: query,
      offset: offset,
      priceLow: priceLow,
      priceHigh: priceHigh,
      sortBy: filterType,
      rating: rating,
      categories: categories,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _searchProductModel = ProductModel.fromJson(apiResponse.response?.data);
      } else {
        _searchProductModel?.totalSize = ProductModel.fromJson(
          apiResponse.response?.data,
        ).totalSize;
        _searchProductModel?.offset = ProductModel.fromJson(
          apiResponse.response?.data,
        ).offset;
        _searchProductModel?.products?.addAll(
          ProductModel.fromJson(apiResponse.response?.data).products ?? [],
        );
      }

      _updateFilterStateFromModel();
    } else {
      _searchProductModel = ProductModel(products: []);
      ApiCheckerHelper.checkApi(apiResponse);
    }

    notifyListeners();
  }

  void _updateFilterStateFromModel() {
    final model = _searchProductModel;
    if (model == null) return;
    _lowerValue = _userPriceLow != null ? model.filterPriceLow : null;
    _upperValue = _userPriceHigh != null ? model.filterPriceHigh : null;
    _selectedSortBy = _userSortBy != null ? model.sortBy : null;
    _selectedRatingIndex = _userRating != null && model.rating != null
        ? 5 - model.rating!
        : null;

    _selectedPriceIndex = null;
    if (_lowerValue != null && _upperValue != null) {
      for (int i = 0; i < AppConstants.priceRanges.length; i++) {
        if (_lowerValue == AppConstants.priceRanges[i][0] &&
            _upperValue == AppConstants.priceRanges[i][1]) {
          _selectedPriceIndex = i;
          break;
        }
      }
    }

    _selectedCategories =
        (model.categories != null && model.categories!.isNotEmpty)
        ? List.from(model.categories!)
        : [];
  }

  void initHistoryList() {
    _historyList = [];
    _historyList.addAll(searchRepo!.getSearchAddress());
  }

  void saveSearchAddress(String? searchAddress, {bool isUpdate = true}) async {
    if (!_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
      searchRepo!.saveSearchAddress(searchAddress);
      if (isUpdate) {
        notifyListeners();
      }
    }
  }

  void clearSearchAddress() async {
    searchRepo!.clearSearchAddress();
    _historyList = [];
    notifyListeners();
  }
}
