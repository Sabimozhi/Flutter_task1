import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/fruits.dart';
import 'package:task1/providers/fruit_list_provider.dart';

class DeleteWidget extends StatelessWidget {
  const DeleteWidget(this.fruit, {super.key});
  final Fruits fruit;

  @override
  Widget build(BuildContext context) {
    return Consumer<FruitsListProvider>(
      builder: (context, fruitsProvider, child) {
        return AlertDialog(
          title: Text("Delete Fruit"),
          content: Text("Are you sure you want to delete ${fruit.name}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final deletedFruit = fruit.name;
                fruitsProvider.removeFruit(fruit);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$deletedFruit deleted")),
                );
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
