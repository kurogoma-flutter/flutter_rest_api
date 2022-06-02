import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rest_api/debug_function.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // APIのレスポンスを格納する
  late Map<String, dynamic> bookInfo;
  late Map<String, dynamic> saleInfo;
  bool isFetching = true;

  Future<void> getData() async {
    var response = await http
        .get(Uri.https('www.googleapis.com', '/books/v1/volumes/${widget.id}'));
    var jsonResponse = jsonDecode(response.body);

    setState(() {
      bookInfo = Map<String, dynamic>.from(jsonResponse['volumeInfo']);
      saleInfo = Map<String, dynamic>.from(jsonResponse['saleInfo']);
      isFetching = false;
    });
  }

  void _launchURL(String linkText) async {
    var url = Uri.parse(linkText);
    // 正しいURLかチェックする
    if (await canLaunchUrl(url)) {
      // URLを開く
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _authorsText(List authors) {
    String text = '';
    int index = 1;
    for (final author in authors) {
      text += author;
      if (index != authors.length) {
        text += '/';
      }
      index++;
    }
    return text;
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isFetching
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('書籍詳細'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
            ),
            body: ListView(
              children: <Widget>[
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    bookInfo['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    height: 160,
                    child: GestureDetector(
                        // child: Container(color: Colors.red, width: 30, height: 30),
                        child: Image.network(bookInfo['imageLinks']['small']),
                        onTap: () {
                          _launchURL(saleInfo['buyLink']);
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('販売価格'),
                      const SizedBox(width: 20),
                      Text('¥ ${saleInfo['listPrice']['amount'].toString()}'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('著者'),
                      const SizedBox(width: 20),
                      Text(_authorsText(bookInfo['authors'])),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('出版社'),
                      const SizedBox(width: 20),
                      Text(bookInfo['publisher']),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('書籍概要',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      Html(data: bookInfo['description']),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
