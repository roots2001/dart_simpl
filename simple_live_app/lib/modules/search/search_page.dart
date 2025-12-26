import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/search/search_controller.dart';
import 'package:simple_live_app/modules/search/search_list_view.dart';

class SearchPage extends GetView<AppSearchController> {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: controller.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "搜点什么吧",
            border: OutlineInputBorder(
              borderRadius: AppStyle.radius24,
            ),
            contentPadding: AppStyle.edgeInsetsH12,
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back),
                ),
                Obx(
                  () => DropdownButton<int>(
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("房间"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("主播"),
                      ),
                    ],
                    value: controller.searchMode.value,
                    onChanged: (e) {
                      controller.searchMode.value = e ?? 0;
                      controller.doSearch();
                    },
                  ),
                ),
                AppStyle.hGap8,
              ],
            ),
            suffixIcon: IconButton(
              onPressed: controller.doSearch,
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (e) {
            controller.doSearch();
          },
          onTap: () {
            // 点击输入框时显示历史
            if (controller.searchController.text.isEmpty) {
              controller.showSearchHistory.value = true;
            }
          },
        ),
        bottom: TabBar(
          controller: controller.tabController,
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.center,
          tabs: Sites.supportSites
              .map(
                (e) => Tab(
                  //text: e.name,
                  child: Row(
                    children: [
                      Image.asset(
                        e.logo,
                        width: 24,
                      ),
                      AppStyle.hGap8,
                      Text(e.name),
                    ],
                  ),
                ),
              )
              .toList(),
          labelPadding: AppStyle.edgeInsetsH20,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.tabController,
            children: Sites.supportSites
                .map((e) => SearchListView(
                          e.id,
                        )
                    // (e) => e.id == Constant.kDouyin
                    //     ? const DouyinSearchView()
                    //     : SearchListView(
                    //         e.id,
                    //       ),
                    )
                .toList(),
          ),
          // 搜索历史层
          Obx(
            () => controller.showSearchHistory.value &&
                    controller.searchHistory.isNotEmpty
                ? buildSearchHistory()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // 构建搜索历史列表
  Widget buildSearchHistory() {
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppStyle.edgeInsetsA12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "搜索历史",
                  style: Get.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text("提示"),
                        content: const Text("确定要清空搜索历史吗？"),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.clearHistory();
                              Get.back();
                            },
                            child: const Text("确定"),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text("清空"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: AppStyle.edgeInsetsH12,
                itemCount: controller.searchHistory.length,
                itemBuilder: (context, index) {
                  final keyword = controller.searchHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(keyword),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        controller.removeHistoryItem(keyword);
                      },
                    ),
                    onTap: () {
                      controller.searchWithHistory(keyword);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
