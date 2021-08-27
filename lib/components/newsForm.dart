import 'dart:convert';
import 'package:crud/components/newsTextFormField.dart';
import 'package:crud/constants/color.dart';
import 'package:crud/constants/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsForm extends StatefulWidget {
  String? title;
  String? author;
  String? content;
  dynamic item;
  bool isEditing;

  NewsForm({
    this.title = '',
    this.author = '',
    this.content = '',
    this.item,
    this.isEditing = false
  });

  @override
  _NewsFormState createState() => _NewsFormState();
}

class _NewsFormState extends State<NewsForm> {
  final color = ProjectColors();
  final _formKey = GlobalKey<FormState>();
  final _env = Env();

  TextEditingController _titleCtrl = TextEditingController();
  TextEditingController _authorCtrl = TextEditingController();
  TextEditingController _contentCtrl = TextEditingController();
  FocusNode _titleFocusNode = FocusNode();
  FocusNode _authorFocusNode = FocusNode();
  FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() { 
    super.initState();
    setState(() {
      _titleCtrl = TextEditingController(
        text: widget.title!.isNotEmpty ? widget.title : null
      );
      _authorCtrl = TextEditingController(
        text: widget.author!.isNotEmpty ? widget.author : null
      );
      _contentCtrl = TextEditingController(
        text: widget.content!.isNotEmpty ? widget.content : null
      );
    });
  }

  _sendForm() async {
    if (_formKey.currentState!.validate()) {
      http.Response response;

      if(widget.isEditing) {
        String itemId = widget.item['_id'];

        Map<String, dynamic> objData = {
          ...widget.item,
          'title': _titleCtrl.text,
          'author': _authorCtrl.text,
          'content': _contentCtrl.text
        };
        response = await http.put(
          Uri.parse('${_env.baseUrl}/news/$itemId'),
          headers: {
            'Content-type': 'application/json; charset=utf-8'
          },
          body: jsonEncode(objData)
        );
      } else {
        Map<String, String> objData = {
          'title': _titleCtrl.text,
          'author': _authorCtrl.text,
          'img': '',
          'content': _contentCtrl.text
        };

        response = await http.post(
          Uri.parse('${_env.baseUrl}/news'),
          headers: {
            'Content-type': 'application/x-www-form-urlencoded'
          },
          body: objData
        );
      }
      
      var body = jsonDecode(response.body);

      try {
        if(!body['status']) {
          _handleSnackBar(body['msg']['message']);
        } else {
          FocusManager.instance.primaryFocus?.unfocus();
          _handleSnackBar(body['msg']);
          Navigator.pop(context, true);
        }
      } catch(e) {
        _handleSnackBar(e.toString());
        throw Exception(e);
      }
    }
  }

  _handleSnackBar(String value) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Adicionar notícia'),
          backgroundColor: color.primaryColor,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.close),
                onPressed: () { Navigator.pop(context, false); },
                tooltip: 'Fechar',
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NewsTextFormField(
                    textController: _titleCtrl,
                    focusNode: _titleFocusNode,
                    label: 'Título',
                    validatorMsg: 'Digite algo',
                  ),
                  NewsTextFormField(
                    textController: _authorCtrl,
                    focusNode: _authorFocusNode,
                    label: 'Autor',
                    validatorMsg: 'Digite algo',
                  ),
                  NewsTextFormField(
                    textController: _contentCtrl,
                    focusNode: _contentFocusNode,
                    label: 'Digite aqui...',
                    validatorMsg: 'Uma notícia deve ter no mínimo 15 caracteres',
                    minCharacters: 15,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 20,
                    isTextArea: true,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ElevatedButton(
                      onPressed: _sendForm,
                      child: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        primary: color.primaryColor,
                        minimumSize: Size(double.infinity, 35)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}