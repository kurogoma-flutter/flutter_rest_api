import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(title: 'Flutter REST API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // APIのレスポンスを格納する
  List items = [];

  Future<void> getData() async {
    var response = await http.get(Uri.https(
        'www.googleapis.com',
        '/books/v1/volumes',
        {'q': '{Flutter}', 'maxResults': '40', 'langRestrict': 'ja'}));

    var jsonResponse = jsonDecode(response.body);

    setState(() {
      items = jsonResponse['items'];
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter REST API'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Image.network(
                    items[index]['volumeInfo']['imageLinks']['thumbnail'],
                  ),
                  title: Text(items[index]['volumeInfo']['title']),
                  subtitle: Text(items[index]['volumeInfo']['publishedDate']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
