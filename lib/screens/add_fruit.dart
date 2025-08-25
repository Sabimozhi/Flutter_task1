import 'package:flutter/material.dart';
import 'package:task1/fruits.dart';

class AddFruitWidget extends StatefulWidget {
  const AddFruitWidget({super.key});

  @override
  State<AddFruitWidget> createState() => _AddFruitWidgetState();
}

class _AddFruitWidgetState extends State<AddFruitWidget> {
  String _fruitName = '';
  String _description = '';
  String _quantity = '';
  final _formKey = GlobalKey<FormState>();

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        Fruits(
          name: _fruitName,
          quantity: _quantity,
          description: _description,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Fruits'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 15,
              children: [
                //fruitname
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Fruit Name',
                    hint: Text('Enter the fruit name'),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fruit name must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) => _fruitName = value!,
                ),

                //Quantity
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hint: Text('Enter number of fruits'),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fruit name must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) => _quantity = value!,
                ),

                //description
                TextFormField(
                  maxLength: 30,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hint: Text('Enter 1 line description'),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) => _description = value!,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(onPressed: _onSave, child: Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
