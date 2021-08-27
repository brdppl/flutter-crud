import 'package:crud/constants/color.dart';
import 'package:flutter/material.dart';

class NewsTextFormField extends StatefulWidget {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final String label;
  String? validatorMsg;
  TextInputType? keyboardType;
  int? minLines;
  int? maxLines;
  bool? isTextArea;
  int? minCharacters;

  NewsTextFormField({
    required this.textController,
    required this.focusNode,
    required this.label,
    this.validatorMsg,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.isTextArea = false,
    this.minCharacters = 10
  });

  @override
  _NewsTextFormFieldState createState() => _NewsTextFormFieldState();
}

class _NewsTextFormFieldState extends State<NewsTextFormField> {
  final color = ProjectColors();

  _validator(dynamic value, String? msg) {
    if(widget.isTextArea == false) {
      if (value == null || value.isEmpty) {
        return msg;
      }
    } else {
      if (value.length < widget.minCharacters) {
        return msg;
      }
    }
    return null;
  }

  void _requestFocus(FocusNode focusNodeName){
    setState(() {
      FocusScope.of(context).requestFocus(focusNodeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        validator: (value) => _validator(value, widget.validatorMsg),
        controller: widget.textController,
        focusNode: widget.focusNode,
        onTap: () => _requestFocus(widget.focusNode),
        cursorColor: color.primaryColor,
        keyboardType: widget.keyboardType,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.focusNode.hasFocus
              ? color.primaryColor
              : null
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: color.primaryColor,
              width: 2
            )
          )
        ),
      )
    );
  }
}