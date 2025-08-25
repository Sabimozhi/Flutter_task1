import 'package:flutter/material.dart';
import 'package:task1/fruits.dart';

class FruitsListProvider extends ChangeNotifier {
  final List<Fruits> _fruits = [
    Fruits(name: 'Apple', quantity: '5', description: 'Red and sweet'),
    Fruits(name: 'Banana', quantity: '12', description: 'Yellow and soft'),
    Fruits(name: 'Orange', quantity: '8', description: 'Citrus and juicy'),
    Fruits(name: 'Mango', quantity: '6', description: 'Tropical and sweet'),
    Fruits(name: 'Pineapple', quantity: '3', description: 'Tropical and tangy'),
    Fruits(
      name: 'Watermelon',
      quantity: '2',
      description: 'Green outside, red inside',
    ),
    Fruits(name: 'Papaya', quantity: '4', description: 'Orange and soft'),
    Fruits(
      name: 'Strawberry',
      quantity: '15',
      description: 'Small, red, juicy',
    ),
    Fruits(name: 'Guava', quantity: '7', description: 'Green and crunchy'),
    Fruits(name: 'Pear', quantity: '5', description: 'Green and sweet'),
  ];

  List<Fruits> get fruits => _fruits;

  void addFruit(Fruits fruit) {
    _fruits.add(fruit);
    notifyListeners();
  }

  void removeFruit(Fruits fruit) {
    _fruits.remove(fruit);
    notifyListeners();
  }

  void increaseQuantity(Fruits fruit) {
    final index = _fruits.indexOf(fruit);
    int q = int.parse(_fruits[index].quantity);
    _fruits[index].quantity = (q + 1).toString();
    notifyListeners();
  }

  void decreaseQuantity(Fruits fruit) {
    final index = _fruits.indexOf(fruit);
    int q = int.parse(_fruits[index].quantity);
    if (q > 0) {
      _fruits[index].quantity = (q - 1).toString();
      notifyListeners();
    }
  }
}
