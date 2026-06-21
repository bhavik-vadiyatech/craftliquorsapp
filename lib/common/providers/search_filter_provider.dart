import 'package:flutter/cupertino.dart';
import '../../utill/app_constants.dart';
import '../../features/search/providers/search_provider.dart';
import '../../features/category/providers/category_provider.dart';

class SearchFilterProvider extends ChangeNotifier {
  double? _lowerValue;
  double? _upperValue;
  int? _selectedRatingIndex;
  int? _selectedPriceIndex;
  String? _selectedSortBy;
  List<int> _selectedCategories = [];

  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;
  int? get selectedRatingIndex => _selectedRatingIndex;
  int? get selectedPriceIndex => _selectedPriceIndex;
  String? get selectedSortBy => _selectedSortBy;
  List<int> get selectedCategories => _selectedCategories;
  
  bool get hasAnySelection =>
      _selectedRatingIndex != null ||
      _selectedPriceIndex != null ||
      _selectedSortBy != null ||
      _selectedCategories.isNotEmpty;

  void setSortBy(String? value) {
    _selectedSortBy = (_selectedSortBy == value) ? null : value;
    notifyListeners();
  }

  void setRating(int? index) {
    _selectedRatingIndex = (_selectedRatingIndex == index) ? null : index;
    notifyListeners();
  }

  void setPrice(int? index) {
    if (_selectedPriceIndex == index) {
      _selectedPriceIndex = null;
      _lowerValue = null;
      _upperValue = null;
    } else {
      _selectedPriceIndex = index;
      if (index != null) {
        final ranges = AppConstants.priceRanges;
        _lowerValue = ranges[index][0];
        _upperValue = ranges[index][1];
      }
    }
    notifyListeners();
  }

  void toggleCategory(int id) {
    if (_selectedCategories.contains(id)) {
      _selectedCategories.remove(id);
    } else {
      _selectedCategories.add(id);
    }
    notifyListeners();
  }

  void prefill({
    String? sortBy,
    int? rating,
    double? priceLow,
    double? priceHigh,
    List<int>? categories,
  }) {
    _selectedSortBy = sortBy;
    _selectedRatingIndex = rating != null ? 5 - rating : null;
    _lowerValue = priceLow;
    _upperValue = priceHigh;
    _selectedPriceIndex = _matchPriceIndex(priceLow, priceHigh);
    _selectedCategories = categories != null ? List<int>.from(categories) : [];
  }
  static int? _matchPriceIndex(double? low, double? high) {
    if (low == null || high == null) return null;
    for (int i = 0; i < AppConstants.priceRanges.length; i++) {
      if (low == AppConstants.priceRanges[i][0] && high == AppConstants.priceRanges[i][1]) {
        return i;
      }
    }
    return null;
  }

  void reset() {
    _lowerValue = null;
    _upperValue = null;
    _selectedRatingIndex = null;
    _selectedPriceIndex = null;
    _selectedSortBy = null;
    _selectedCategories = [];
    notifyListeners();
  }
  
  void applySearchFilter(SearchProvider searchProvider) {
    int? rating;
    if (_selectedRatingIndex != null) {
      rating = 5 - _selectedRatingIndex!;
    }
    searchProvider.getSearchProduct(
      offset: 1,
      query: searchProvider.searchText,
      priceLow: _lowerValue,
      priceHigh: _upperValue,
      filterType: _selectedSortBy,
      rating: rating,
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      isUpdate: true,
    );
  }
  
  void resetSearchFilter(SearchProvider searchProvider) {
    reset();
    searchProvider.clearFilters();
    searchProvider.getSearchProduct(
      offset: 1,
      query: searchProvider.searchText,
      isUpdate: true,
    );
  }
  
  void applyCategoryFilter(CategoryProvider categoryProvider, String categoryId) {
    int? rating;
    if (_selectedRatingIndex != null) {
      rating = 5 - _selectedRatingIndex!;
    }
    final int selectedIndex = categoryProvider.selectedCategoryIndex;
    final String effectiveCategoryId = (selectedIndex != -1 &&
            categoryProvider.subCategoryList != null &&
            categoryProvider.subCategoryList!.length > selectedIndex)
        ? categoryProvider.subCategoryList![selectedIndex].id.toString()
        : categoryId;
    categoryProvider.initCategoryProductList(
      effectiveCategoryId,
      1,
      priceLow: _lowerValue,
      priceHigh: _upperValue,
      sortBy: _selectedSortBy,
      rating: rating,
    );
  }
  
  void resetCategoryFilter(CategoryProvider categoryProvider, String categoryId) {
    reset();
    categoryProvider.clearCategoryFilter();
    final int selectedIndex = categoryProvider.selectedCategoryIndex;
    final String effectiveCategoryId = (selectedIndex != -1 &&
            categoryProvider.subCategoryList != null &&
            categoryProvider.subCategoryList!.length > selectedIndex)
        ? categoryProvider.subCategoryList![selectedIndex].id.toString()
        : categoryId;
    categoryProvider.initCategoryProductList(effectiveCategoryId, 1);
  }
}