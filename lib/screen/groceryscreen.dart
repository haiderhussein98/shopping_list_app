import 'dart:convert';
import 'package:shoping_list/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:shoping_list/Widget.dart/info.dart';
import 'package:shoping_list/screen/new_itemscreen.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class Groceryscreen extends StatefulWidget {
  const Groceryscreen({super.key});

  @override
  State<Groceryscreen> createState() => _GroceryscreenState();
}

var isloading = true;

List<GroceryItem> myitem = [];
String? error;

class _GroceryscreenState extends State<Groceryscreen> {
  Future<List<GroceryItem>> loaditem() async {
    final url = Uri.https('flutter-shopinglist-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(
        () {
          error = 'filed to load data , please try ageain later !';
        },
      );
    }

    if (response.body == 'null') {
      return [];
    }

    final List<GroceryItem> loaddata = [];

    final Map<String, dynamic> listdata = json.decode(response.body);

    for (final item in listdata.entries) {
      final catgory = categories.entries
          .firstWhere(
            (itemcatg) => itemcatg.value.name == item.value['category'],
          )
          .value;

      loaddata.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: catgory),
      );
    }
    return loaddata;
  }

  @override
  void initState() {
    super.initState();
    loaditem();
  }

  void additem() async {
    final newitem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (ctx) => const NewItemscreen(),
      ),
    );
    if (newitem == null) {
      return;
    }
    setState(() {
      myitem.add(newitem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'your Groceries',
        ),
        actions: [
          IconButton(
            onPressed: additem,
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Info(),
    );
  }
}
