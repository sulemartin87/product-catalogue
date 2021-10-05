import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

void main() => runApp(new MaterialApp(
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/store.json');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }

  Future<File> writeCounter(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = new TextEditingController();
  SharedPreferences sharedPreferences;
  final storage = new CounterStorage();
  final formKey = new GlobalKey<FormState>();
  String _name;
  double _lowPrice;
  double _medPrice;
  double _highPrice;

  @override
  void initState() {
    super.initState();
    loadSharedPreferencesAndData();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();

    loadData();
  }

  loadData() {
    String listString = sharedPreferences.getString('list');
    addProducts(listString);
  }

  addProducts(listString) {
    setState(() {
      for (Map user in json.decode(listString)) {
        _productDetails.add(ProductDetails.fromJson(user));
        print(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar:
          new AppBar(title: new Text('Home'), elevation: 0.0, actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share database',
          onPressed: () {
            shareJson();
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'load database',
          onPressed: () {
            loadJson();
          },
        ),
      ]),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? buildList(_searchResult)
                : buildList(_productDetails),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Add Product'),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            onSaved: (value) => _name = value,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              icon: Icon(Icons.account_box),
                            ),
                          ),
                          TextFormField(
                            onSaved: (value) => _lowPrice = double.parse(value),
                            decoration: InputDecoration(
                              labelText: 'Low',
                              icon: Icon(Icons.email),
                            ),
                          ),
                          TextFormField(
                            // onSaved: (value) => _amount = value,
                            onSaved: (value) => _medPrice = double.parse(value),
                            decoration: InputDecoration(
                              labelText: 'Medium',
                              icon: Icon(Icons.email),
                            ),
                          ),
                          TextFormField(
                            // onSaved: (value) => _amount = value,
                            onSaved: (value) =>
                                _highPrice = double.parse(value),
                            decoration: InputDecoration(
                              labelText: 'High',
                              icon: Icon(Icons.email),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    RaisedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          final form = formKey.currentState;
                          form.save();
                          ProductDetails j = new ProductDetails(
                            name: _name,
                            low: _lowPrice,
                            med: _medPrice,
                            high: _highPrice,
                          );
                          setState(() {
                            _productDetails.add(j);
                          });
                          print(jsonEncode(_productDetails));
                          saveData();
                          Navigator.pop(context, false);
                        })
                  ],
                );
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void shareJson() async {
    storage.writeCounter(json.encode(_productDetails));
    final path = await storage._localPath;
    Share.shareFiles(['$path/store.json'], text: 'Product database');
  }

  void loadJson() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);

      var fil = await file.readAsString();
      await sharedPreferences.setString('list', jsonEncode(fil));
      setState(() {
        addProducts(fil);
      });
    } else {}
  }

  double calculateVat(double value) {
    return value + (value * 0.165);
  }

  buildList(items) {
    return GridView.count(
        crossAxisCount: 2,
        children: List.generate(items.length, (index) {
          var vat = items[index].vat;
          var n = items[index].name;
          var l = items[index].low;
          var m = items[index].med;
          var h = items[index].high;
          var myCard = (left, right) => {
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(left),
                      Text(right),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      items[index].vat = double.parse(right);
                    });
                  },
                )
              };
          return Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Card(
                    elevation: 8.0,
                    child: Column(
                      children: [
                        new ListTile(
                          leading: new IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              int idx = (items[index].originalIndex == null
                                  ? index
                                  : items[index].originalIndex);
                              print(idx.toString());
                              setState(() {
                                _name = items[index].name;
                                _lowPrice = items[index].low;
                                _medPrice = items[index].med;
                                _highPrice = items[index].high;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: Text('Add Product'),
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Form(
                                          key: formKey,
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                initialValue: items[index].name,
                                                onSaved: (value) =>
                                                    _name = value,
                                                decoration: InputDecoration(
                                                  labelText: 'Name',
                                                  icon: Icon(Icons.account_box),
                                                ),
                                              ),
                                              TextFormField(
                                                initialValue:
                                                    items[index].low.toString(),
                                                onSaved: (value) => _lowPrice =
                                                    double.parse(value),
                                                decoration: InputDecoration(
                                                  labelText: 'Low',
                                                  icon: Icon(Icons.email),
                                                ),
                                              ),
                                              TextFormField(
                                                initialValue:
                                                    items[index].med.toString(),
                                                onSaved: (value) => _medPrice =
                                                    double.parse(value),
                                                decoration: InputDecoration(
                                                  labelText: 'Medium',
                                                  icon: Icon(Icons.email),
                                                ),
                                              ),
                                              TextFormField(
                                                initialValue: items[index]
                                                    .high
                                                    .toString(),
                                                onSaved: (value) => _highPrice =
                                                    double.parse(value),
                                                decoration: InputDecoration(
                                                  labelText: 'High',
                                                  icon: Icon(Icons.email),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        RaisedButton(
                                            child: Text("Submit"),
                                            onPressed: () {
                                              final form = formKey.currentState;
                                              form.save();
                                              _productDetails[idx].name = _name;
                                              _productDetails[idx].low =
                                                  _lowPrice;
                                              _productDetails[idx].med =
                                                  _medPrice;
                                              _productDetails[idx].high =
                                                  _highPrice;

                                              items[index].name = _name;
                                              items[index].low = _lowPrice;
                                              items[index].med = _medPrice;
                                              items[index].high = _highPrice;

                                              setState(() {});
                                              saveData();
                                              Navigator.pop(context, false);
                                            })
                                      ],
                                    );
                                  });
                            },
                          ),
                          trailing: new IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              int idx = (items[index].originalIndex == null
                                  ? index
                                  : items[index].originalIndex);
                              setState(() {
                                _productDetails.removeAt(idx);
                                _searchResult.clear();
                              });
                              saveData();
                            },
                          ),
                          title: new Text(n.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Column(
                          children: [
                            ...myCard('low', '$l'),
                            ...myCard('med', '$m'),
                            ...myCard('high', '$h'),
                            ...myCard('plus VAT',
                                '${vat == null ? calculateVat(l).toString() : calculateVat(vat).toString()}'),
                          ],
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(0.0),
                  ),
                ),
              ],
            ),
          );
        }));
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _productDetails.asMap().forEach((index, userDetail) {
      if (userDetail.name.contains(text.toUpperCase())) {
        userDetail.originalIndex = index;
        _searchResult.add(userDetail);
      }
    });

    setState(() {});
  }

  void saveData() {
    sharedPreferences.setString('list', jsonEncode(_productDetails));
  }
}

List<ProductDetails> _searchResult = [];

List<ProductDetails> _productDetails = [];

class ProductDetails {
  String name;
  double low, med, high, selected, vat;
  int originalIndex;

  ProductDetails(
      {this.name,
      this.low,
      this.med,
      this.high,
      this.selected,
      this.vat,
      this.originalIndex});
  Map<String, dynamic> toJson() => {
        "name": name,
        "low": low.toString(),
        "med": med.toString(),
        "high": high.toString(),
      };
  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    var name = json['name'];
    var low = json['low'] ?? '0';
    var med = json['med'] ?? '0';
    var high = json['high'] ?? '0';

    return new ProductDetails(
      name: name.toUpperCase(),
      low: double.parse(low.replaceAll(',', '')),
      med: double.parse(med.replaceAll(',', '')),
      high: double.parse(high.replaceAll(',', '')),
    );
  }
}
