import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'item.dart';

const COLLECTION_NAME = 'Busket_item';

class Busket extends StatefulWidget {
  const Busket({Key? key}) : super(key: key);

  @override
  State<Busket> createState() => _BusketState();
}

class _BusketState extends State<Busket> {
  List<Item> busketItems = [];
  @override
  void initState() {
    fetchRecords();
    // This will auto update the recorde without hot reloding, as the new recorded is entered
    FirebaseFirestore.instance
        .collection('Busket_item')
        .snapshots()
        .listen((records) {
      mapRecords(records);
    });
    super.initState();
  }

  fetchRecords() async {
    var records =
        await FirebaseFirestore.instance.collection('Busket_item').get();
    mapRecords(records);
  }

  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    var list = records.docs
        .map(
          (item) =>
              Item(id: item.id, name: item['name'], quantity: item['quantity']),
        )
        .toList();
    setState(() {
      busketItems = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: showItemDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: busketItems.length,
          itemBuilder: ((context, index) {
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (c) {
                      deleteItem(busketItems[index].id);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: "Delete",
                    spacing: 8,
                  ),
                ],
              ),
              child: ListTile(
                title: Text(busketItems[index].name),
                subtitle: Text(busketItems[index].quantity ?? ''),
              ),
            );
          })),
    );
  }

  showItemDialog() {
    var nameController = TextEditingController();
    var quantityController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    const Text('Basket Item'),
                    TextField(
                      controller: nameController,
                    ),
                    TextField(
                      controller: quantityController,
                    ),
                    TextButton(
                        onPressed: () {
                          var name = nameController.text.trim();
                          var quantity = quantityController.text.trim();
                          addItem(name, quantity);
                          Navigator.pop(context);
                        },
                        child: const Text("Add"))
                  ],
                ),
              ),
            ),
          );
        });
  }
}

addItem(String name, String quantity) {
  var item = Item(id: "id", name: name, quantity: quantity);
  FirebaseFirestore.instance.collection(COLLECTION_NAME).add(item.toJson());
}

deleteItem(String id) {
  FirebaseFirestore.instance.collection(COLLECTION_NAME).doc(id).delete();
}
