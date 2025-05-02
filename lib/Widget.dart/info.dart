import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/screen/groceryscreen.dart';
import 'package:http/http.dart' as http;

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  Future<void> deleteitem(GroceryItem item) async {
    final index = myitem.indexOf(item);
    setState(() {
      myitem.remove(item);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('remove had scssuasfully'),
          ),
        );
      });
    });
    final url = Uri.https('flutter-shopinglist-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        myitem.insert(index, item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('remove field , try againe'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget maincontent;
    if (isloading) {
      maincontent = Center(
        child: CircularProgressIndicator(),
      );
    }
    if (myitem.isEmpty) {
      maincontent = Center(
        child: Text(
          'no item to display it , add one!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      maincontent = ListView.builder(
        itemCount: myitem.length,
        itemBuilder: (ctx, index) => Dismissible(
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (direction) {
            deleteitem(myitem[index]);
          },
          key: Key(myitem[index].id),
          child: ListTile(
            title: Text(myitem[index].name),
            leading: Container(
              width: 20,
              height: 20,
              color: myitem[index].category.color,
            ),
            trailing: Text(myitem[index].quantity.toString()),
          ),
        ),
      );
    }
    return maincontent;
  }
}
