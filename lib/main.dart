import 'package:flutter/material.dart';
import 'package:flutter_rest_api/detail_page.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const MyHomePage(title: 'Flutter REST API'),
      ),
      GoRoute(
        path: '/book/:id', // 本の詳細を取得
        builder: (context, state) {
          // パスパラメータの値を取得するには state.params を使用
          final String id = state.params['id']!;
          return BookDetailPage(id: id);
        },
      ),
    ],
    initialLocation: '/',
  );
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
        {'q': '{Flutter}', 'maxResults': '35', 'langRestrict': 'ja'}));

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
                items[index] != null
                    ? GestureDetector(
                        child: ListTile(
                          leading: Image.network(
                            items[index]['volumeInfo']['imageLinks']
                                    ['thumbnail'] ??
                                '',
                          ),
                          title:
                              Text(items[index]['volumeInfo']['title'] ?? ''),
                          subtitle: Text(items[index]['volumeInfo']
                                  ['publishedDate'] ??
                              ''),
                        ),
                        onTap: () {
                          // 詳細画面へ遷移
                          context.go('/book/${items[index]['id']}');
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }
}
