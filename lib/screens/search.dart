import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/providers/fruit_list_provider.dart';
import 'package:task1/screens/delete.dart';
import 'package:task1/screens/fruits_card.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key});

  final searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: searchController,
      builder: (BuildContext context, SearchController searchController) {
        return IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            searchController.openView();
          },
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController searchController) {
            final fruitsProvider = Provider.of<FruitsListProvider>(
              context,
              listen: false,
            );
            final query = searchController.text.toLowerCase();
            final results = fruitsProvider.fruits
                .where(
                  (fruit) =>
                      fruit.name.toLowerCase().contains(query) ||
                      fruit.quantity.contains(query),
                )
                .toList();
            return results.map((fruit) {
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DeleteWidget(fruit);
                    },
                  );
                },

                child: FruitsCardWidget(fruit),
              );
            });
          },
    );
  }
}
