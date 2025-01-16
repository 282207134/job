import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class testPage2 extends StatefulWidget {
  const testPage2({super.key});

  @override
  State<testPage2> createState() => _testPage2State();
}

class _testPage2State extends State<testPage2> {
///////////////////////
  int _counter = 0;
  File? image;
  late ImagePicker imagePicker;

  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }
  chooseImage(){}
  

////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Container(

    ));
  }
}
