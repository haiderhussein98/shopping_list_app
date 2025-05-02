import 'dart:convert';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/screen/groceryscreen.dart';
import 'package:flutter/material.dart';
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/category.dart';
import 'package:http/http.dart' as http;

class NewItemscreen extends StatefulWidget {
  const NewItemscreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemscreen();
  }
}

class _NewItemscreen extends State<NewItemscreen> {
  final _globalkey = GlobalKey<FormState>();
  var entieredname = '';
  var eniterquintity = 1;
  var selectedcatgory = categories[Categories.carbs]!;

  var issending = false;
  void _saveitem() async {
    if (_globalkey.currentState!.validate()) {
      _globalkey.currentState!.save();
      setState(() {
        issending = true;
      });

      final url = Uri.https('flutter-shopinglist-default-rtdb.firebaseio.com',
          'shopping-list.json');

      try {
        final responde = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'name': entieredname,
              'quantity': eniterquintity,
              'category': selectedcatgory.name,
            },
          ),
        );

        final Map<String, dynamic> listdata = json.decode(responde.body);

        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('item add secsasfully'),
          ),
        );
        Navigator.of(context).pop(
          GroceryItem(
              id: listdata['name'],
              name: entieredname,
              quantity: eniterquintity,
              category: selectedcatgory),
        );
      } catch (error1) {
        error = 'somethink fieled , try againe later !';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _globalkey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) {
                  entieredname = value!;
                },
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text('name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'must be 1 to 50 charictars!';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: eniterquintity.toString(),
                      onSaved: (value) {
                        eniterquintity = int.parse(value!);
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0 ||
                            value.trim().length > 50) {
                          return 'must bea vaild or posative number !';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedcatgory,
                      items: [
                        for (final catgory in categories.entries)
                          DropdownMenuItem(
                            value: catgory.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: catgory.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(catgory.value.name)
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedcatgory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: issending
                        ? null
                        : () {
                            _globalkey.currentState!.reset();
                          },
                    child: Text('rest'),
                  ),
                  ElevatedButton(
                      onPressed: issending ? null : _saveitem,
                      child: issending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('add')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
