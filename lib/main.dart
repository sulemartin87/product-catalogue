import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return '';
    }
  }

  Future<File> writeCounter(String json) async {
    final file = await _localFile;

    // Write the file
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
  // Get json result and convert it to model. Then add
  // Future<Null> getUserDetails() async {
  //   final response = await http.get(url);
  //   final responseJson = json.decode(response.body);
  //
  //   setState(() {
  //     for (Map user in responseJson) {
  //       _productDetails.add(ProductDetails.fromJson(user));
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    loadSharedPreferencesAndData();

    // getUserDetails();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();

    loadData();
  }

  loadData() {
    String listString = sharedPreferences.getString('list');
    // print();

    setState(() {
      for (Map user in json.decode(listString)) {
        _productDetails.add(ProductDetails.fromJson(user));
        print(_productDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Home'),
        elevation: 0.0,
          actions: <Widget>[
      IconButton(
      icon: const Icon(Icons.share),
      tooltip: 'Share database',
      onPressed: () {
        shareJson();
        // final RenderBox box = context.findRenderObject();

        // Share.shareFiles(['${storage .path}/image.jpg'], text: 'Great picture');
        // Share.share(json.encode(_productDetails),
        //     subject: "hey",
        //     sharePositionOrigin:
        //     box.localToGlobal(Offset.zero) &
        //     box.size);
        // scaffoldKey.currentState.showSnackBar(snackBar);
      },
    ),
  ]
      ),
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
                            // accountData.add(j);
                            _productDetails.add(j);
                          });
                          // print(json.encode(accountData));
                          // List<String> strList = _productDetails.map((e) => jsonEncode(e));
                          //  _productDetails.map((e) => print(e.toString()));
                          //  _productDetails.map((e) => print(e.vat));
                          // String accountToJson(List<ProductDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
                          // List<String> strList = accountToJson(_productDetails);
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
  void shareJson() async{
    storage.writeCounter(json.encode(_productDetails));
    final path = await storage._localPath;
    Share.shareFiles(['$path/store.json'], text: 'Product database');
  }
  double calculateVat(double value) {
    return value + (value * 0.165);
  }

  buildList(items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
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
                            // formKey.
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
                                              onSaved: (value) => _name = value,
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
                                              // onSaved: (value) => _amount = value,
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
                                              // onSaved: (value) => _amount = value,
                                              initialValue:
                                                  items[index].high.toString(),
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
                        title: new Text(items[index].name.toUpperCase(),
                            style: TextStyle(fontSize: 25)),
                      ),
                      Text.rich(TextSpan(
                        children: <InlineSpan>[
                          WidgetSpan(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                'Low MWK ${items[index].low.toString()}',
                                style: new TextStyle(color: Colors.white),
                              ),
                              // color: Colors.blue,
                              color: ((items[index].vat == items[index].low ||
                                      items[index].vat == null)
                                  ? Colors.blue
                                  : Colors.blueGrey),
                              onPressed: () {
                                // To do
                                setState(() {
                                  items[index].vat = items[index].low;
                                });
                              },
                            ),
                          ),
                          WidgetSpan(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                  'Med MWK ${items[index].med.toString()}',
                                  style: new TextStyle(color: Colors.white)),
                              color: (items[index].vat == items[index].med
                                  ? Colors.blue
                                  : Colors.blueGrey),
                              onPressed: () {
                                // To do
                                setState(() {
                                  items[index].vat = items[index].med;
                                });
                              },
                            ),
                          ),
                          WidgetSpan(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),

                              child: Text(
                                'High MWK ${items[index].high.toString()}',
                                style: new TextStyle(color: Colors.white),
                              ),
                              color: (items[index].vat == items[index].high
                                  ? Colors.blue
                                  : Colors.blueGrey),
                              // color: Colors.blue,
                              onPressed: () {
                                // To do
                                setState(() {
                                  items[index].vat = items[index].high;
                                });
                              },
                            ),
                          ),
                          WidgetSpan(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                  'VAT MWK ${items[index].vat == null ? calculateVat(items[index].low).toString() : calculateVat(items[index].vat).toString()}'),
                              color: Colors.green,
                              onPressed: () {
                                // To do
                              },
                            ),
                          ),
                          // TextSpan(text: 'the best!'),
                        ],
                      )),
                    ],
                  ),
                  margin: const EdgeInsets.all(0.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _productDetails.asMap().forEach((index, userDetail) {
      if (userDetail.name.contains(text)) {
        userDetail.originalIndex = index;
        _searchResult.add(userDetail);
      }
    });

    setState(() {});
  }

  void saveData() {
    // print(data);
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
    return new ProductDetails(
      name: json['name'],
      low: double.parse(json['low']),
      med: double.parse(json['med']),
      high: double.parse(json['high']),
    );
  }
}
