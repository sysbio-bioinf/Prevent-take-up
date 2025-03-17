import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:questionnaires/models/question.dart';
import 'package:questionnaires/screens/questionnaire_screen.dart';

class QuestImage extends StatefulWidget {
  final Question question;
  final int gridSize;
  final List<int> answerIdc;

  const QuestImage(
      {@required key,
      required this.question,
      required this.gridSize,
      required this.answerIdc})
      : super(key: key);

  State<QuestImage> createState() => _QuestImageState();
}

typedef void ImageClickCallback(int index);

class _QuestImageState extends State<QuestImage> {
  //generate
  List<bool> grid = List<bool>.empty(growable: true);
  double _posX = -30;
  double _posY = -30;

  double _percX = -0.5;
  double _percY = -0.5;

  double _maxWidth = 0;
  double _maxHeight = 0;

  late Uint8List imageFile;

  void setCoordinates(BoxConstraints pConstraints) async {
    print("Image :" + this.widget.question.image);
    Uint8List _bytes =
        base64.decode(this.widget.question.image.split(',').last);
    var decodedImage = await decodeImageFromList(_bytes);
    double imageRatio = decodedImage.width / decodedImage.height;

    if (this._maxWidth == 0) {
      setState(() {
        this._maxWidth = pConstraints.maxWidth;
        this._maxHeight = _maxWidth / imageRatio;

        this._posX = this._percX * this._maxWidth;
        this._posY = this._percY * this._maxHeight;
      });
    }
  }

  void initState() {
    super.initState();
    grid.clear();
    grid.addAll(List<bool>.filled(
        (this._maxHeight / this.widget.gridSize).ceil(), false));

    asyncReadFile();
    // if (this.widget.question.selectedUserAnswer == null) {
    //   Map<String, dynamic> questionFromDatabase =
    //       LocalDatabase().getQuestionByID(this.widget.question.id);
    //   if (questionFromDatabase != null) {
    //     String userValueFromDatabase = questionFromDatabase['userAnswer'];

    //     parseStringToCoordinates(userValueFromDatabase);
    //     this.widget.question.setUserAnswer(parseCoordinatesToString());
    //   }
    // } else {
    //   print("existing");

    //   parseStringToCoordinates(this.widget.question.selectedUserAnswer);
    // }
  }

  void asyncReadFile() async {
    Uint8List tmp = await new File(this.widget.question.image).readAsBytes();
    setState(() {
      imageFile = tmp;
    });
  }

  void parseStringToCoordinates(String pString) {
    setState(() {
      this._percX = double.parse(pString.split(';')[0]);
      this._percY = double.parse(pString.split(';')[1]);
    });
  }

  String parseCoordinatesToString() {
    return _percX.toString() + ';' + _percY.toString();
  }

  String onTapDown(BuildContext context, TapDownDetails details) {
    // creating instance of renderbox
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      _posX = localOffset.dx;
      _posY = localOffset.dy;

      _percX = _posX / box.size.width;
      _percY = _posY / box.size.height;
    });
    return parseCoordinatesToString();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List _bytes = imageFile;
    return GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      child: Stack(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            setCoordinates(constraints);
            return Container();
          }),
          Image.memory(
            _bytes,
            fit: BoxFit.fitHeight,
          ),
          Positioned(
            top: _posY - 7,
            left: _posX - 7,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
