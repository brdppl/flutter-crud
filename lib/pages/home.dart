import 'dart:convert';
import 'package:crud/constants/color.dart';
import 'package:crud/constants/env.dart';
import 'package:flutter/material.dart';
import 'package:crud/components/newsForm.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final color = ProjectColors();
  final _env = Env();

  late Future<dynamic> futureNews;
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    print('alive');
    futureNews = fetchNews();
  }

  Future<dynamic> fetchNews() async {
    final response = await http.get(Uri.parse('${_env.baseUrl}/news'));
    var body = jsonDecode(response.body);
    List<dynamic> data = body['data'];

    try {
      setState(() {
        this.newsList = data;
      });
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _refresh() async {
    await fetchNews();
    setState(() {
      futureNews = fetchNews();
    });
  }

  Future<void> _activate(item, bool value) async {
    final Map<String, dynamic> objData = {
      ...item,
      'active': value
    };
    String itemId = item['_id'];

    final response = await http.put(
      Uri.parse('${_env.baseUrl}/news/$itemId'),
      headers: {
        'Content-type': 'application/json; charset=utf-8'
      },
      body: jsonEncode(objData)
    );
    var body = jsonDecode(response.body);
    if(body['status']) {
      _refresh().then((value) => _handleSnackBar(body['msg']));
    }
  }

  Future<void> _delete(id) async {
    final response = await http.delete(Uri.parse('${_env.baseUrl}/news/$id'));
    var body = jsonDecode(response.body);
    if(body['status']) {
      _refresh().then((value) => _handleSnackBar(body['msg']));
    }
  }

  _handleSnackBar(String value) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: color.primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Adicionar',
            onPressed: () async {
              final dialogRef = await Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) => NewsForm(),
                fullscreenDialog: true
              ));
              if(dialogRef) {
                _refresh();
              }
            },
          ),
        ]
      ),
      body: FutureBuilder(
        future: futureNews,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData) {
            return RefreshIndicator(
              color: color.primaryColor,
              onRefresh: () => _refresh(),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var news = this.newsList[index];
                  return Column(
                    children: <Widget>[
                      Slidable(
                        key: UniqueKey(),
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Card(
                          child: SwitchListTile(
                            title: Text(news['title']),
                            subtitle: Text(news['author']),
                            activeColor: color.primaryColor,
                            value: news['active'],
                            onChanged: (value) {
                              setState(() {
                                news['active'] = value;
                              });
                              _activate(news, value);
                            },
                          )
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Editar',
                            color: Colors.blue,
                            icon: Icons.edit,
                            onTap: () async {
                              final dialogRef = await Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) => NewsForm(
                                  title: news['title'],
                                  author: news['author'],
                                  content: news['content'],
                                  isEditing: true,
                                  item: news,
                                ),
                                fullscreenDialog: true
                              ));
                              if(dialogRef) {
                                _refresh();
                              }
                            }
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              setState(() {
                                this.newsList.remove(news);
                              });
                              _delete(news['_id']);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            );
          }
          return Center(
            child: CircularProgressIndicator(color: color.primaryColor)
          );
        },
      )
    );
  }
}