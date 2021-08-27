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

  List<dynamic>? news;

  @override
  void initState() {
    super.initState();
    print('alive');
    fetchNews().then((value) => {
      setState(() {
        this.news = value;
      })
    });
  }

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse('${_env.baseUrl}/news'));
    var body = jsonDecode(response.body);
    List<dynamic> news = body['data'];

    try {
      // return news.where((element) => element['active'] == false).toList();
      return news;
    } catch(e) {
      throw Exception('Failed');
    }
  }

  Future<void> _refresh() async {
    var res = await fetchNews();
    setState(() {
      this.news = res;
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
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['msg'])),
      );
    }
  }

  Future<void> _delete(id) async {
    final response = await http.delete(Uri.parse('${_env.baseUrl}/news/$id'));
    var body = jsonDecode(response.body);
    if(body['status']) {
      _refresh();
    }
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
        future: fetchNews(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData) {
            return RefreshIndicator(
              color: color.primaryColor,
              onRefresh: () => _refresh(),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var news = snapshot.data[index];
                  return Column(
                    children: <Widget>[
                      // Using Dismissible, native from Flutter
                      // Dismissible(
                      //   key: UniqueKey(),
                      //   direction: DismissDirection.endToStart,
                      //   onDismissed: (direction) {
                      //     if(direction == DismissDirection.endToStart) {
                      //       _delete(news['_id']);
                      //     }
                      //   },
                      //   background: Container(
                      //     color: Colors.red,
                      //     child: Align(
                      //       alignment: Alignment.centerRight,
                      //       child: Padding(
                      //         padding: EdgeInsets.only(right: 16),
                      //         child: Icon(Icons.delete, color: Colors.white),
                      //       )
                      //     )
                      //   ),
                      //   child: Card(
                      //     child: ListTile(
                      //       title: Text(news['title']),
                      //       subtitle: Text(news['author']),
                      //       // trailing: Icon(Icons.more_vert)
                      //       trailing: Switch(
                      //         value: news['active'],
                      //         activeColor: color.primaryColor,
                      //         onChanged: (value) {
                      //           _activate(news, value);
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // )
                      Slidable(
                        key: UniqueKey(),
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Card(
                          child: ListTile(
                            title: Text(news['title']),
                            subtitle: Text(news['author']),
                            // trailing: Icon(Icons.more_vert)
                            trailing: Switch(
                              value: news['active'],
                              activeColor: color.primaryColor,
                              onChanged: (value) {
                                _activate(news, value);
                              },
                            ),
                          ),
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
                            onTap: () => _delete(news['_id']),
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