import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/providers/fruit_list_provider.dart';
import 'package:task1/screens/delete.dart';
import 'package:task1/screens/fruits_card.dart';
import 'package:task1/screens/search.dart';

class FruitsListWidget extends StatelessWidget {
  const FruitsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final fruitsProvider = context.watch<FruitsListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fruits'),
        centerTitle: true,
        actions: [SearchWidget()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: fruitsProvider.fruits.length,
          itemBuilder: (context, item) {
            final fruit = fruitsProvider.fruits[item];
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/addFruits');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
