import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/providers/fruit_list_provider.dart';
import 'package:task1/screens/add_fruit.dart';
import 'package:task1/screens/fruits_list.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FruitsListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {'/addFruits': (context) => AddFruitWidget()},
      home: const FruitsListWidget(),
    );
  }
}
