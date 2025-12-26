import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/search/search_list_controller.dart';
import 'package:simple_live_app/services/local_storage_service.dart';

class AppSearchController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  int index = 0;

  var searchMode = 0.obs;
  
  // 搜索历史列表
  var searchHistory = <String>[].obs;
  
  // 是否显示搜索历史
  var showSearchHistory = false.obs;

  AppSearchController() {
    tabController =
        TabController(length: Sites.supportSites.length, vsync: this);
    tabController.animation?.addListener(() {
      var currentIndex = (tabController.animation?.value ?? 0).round();
      if (index == currentIndex) {
        return;
      }

      index = currentIndex;
      // if (Sites.supportSites[index].id == Constant.kDouyin) {
      //   return;
      // }

      var controller =
          Get.find<SearchListController>(tag: Sites.supportSites[index].id);

      if (controller.list.isEmpty &&
          !controller.pageEmpty.value &&
          controller.keyword.isNotEmpty) {
        controller.refreshData();
      }
    });
  }

  StreamSubscription<dynamic>? streamSubscription;

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    // 加载搜索历史
    loadSearchHistory();
    
    // 监听输入框焦点变化
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        showSearchHistory.value = true;
      } else {
        showSearchHistory.value = false;
      }
    });
    
    for (var site in Sites.supportSites) {
      // if (site.id == Constant.kDouyin) {
      //   Get.put(DouyinSearchController(site));
      // } else {
      Get.put(
        SearchListController(site),
        tag: site.id,
      );
      //}
    }

    super.onInit();
  }
  
  /// 加载搜索历史
  void loadSearchHistory() {
    searchHistory.value = LocalStorageService.instance.getSearchHistory();
  }
  
  /// 添加搜索历史
  Future<void> addToHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;
    await LocalStorageService.instance.addSearchHistory(keyword);
    loadSearchHistory();
  }
  
  /// 删除搜索历史项
  Future<void> removeHistoryItem(String keyword) async {
    await LocalStorageService.instance.removeSearchHistory(keyword);
    loadSearchHistory();
  }
  
  /// 清空搜索历史
  Future<void> clearHistory() async {
    await LocalStorageService.instance.clearSearchHistory();
    loadSearchHistory();
  }
  
  /// 使用历史记录搜索
  void searchWithHistory(String keyword) {
    searchController.text = keyword;
    showSearchHistory.value = false;
    doSearch();
  }

  void doSearch() {
    if (searchController.text.isEmpty) {
      return;
    }
    
    // 添加到搜索历史
    addToHistory(searchController.text);
    
    // 隐藏搜索历史
    showSearchHistory.value = false;
    
    for (var site in Sites.supportSites) {
      // if (site.id == Constant.kDouyin) {
      //   var controller = Get.find<DouyinSearchController>();
      //   controller.keyword = searchController.text;
      //   controller.searchMode.value = searchMode.value;
      //   controller.reloadWebView();
      // } else {
      var controller = Get.find<SearchListController>(tag: site.id);
      controller.clear();
      controller.keyword = searchController.text;
      controller.searchMode.value = searchMode.value;
      //}
    }
    // if (Sites.supportSites[index].id != Constant.kDouyin) {
    var controller =
        Get.find<SearchListController>(tag: Sites.supportSites[index].id);
    controller.refreshData();
    //}
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }
}
