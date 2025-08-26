import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/fruits.dart';
import 'package:task1/providers/fruit_list_provider.dart';

class FruitsCardWidget extends StatelessWidget {
  const FruitsCardWidget(this.fruit, {super.key});
  final Fruits fruit;

  @override
  Widget build(BuildContext context) {
    return Consumer<FruitsListProvider>(
      builder: (context, fruitsProvider, child) {
        return Card(
          child: ListTile(
            title: Text(fruit.name),
            subtitle: Text(fruit.description),
            trailing: SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => fruitsProvider.decreaseQuantity(fruit),
                    icon: Icon(Icons.remove, size: 16),
                  ),
                  Text(
                    fruit.quantity,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  IconButton(
                    onPressed: () => fruitsProvider.increaseQuantity(fruit),
                    icon: Icon(Icons.add, size: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
