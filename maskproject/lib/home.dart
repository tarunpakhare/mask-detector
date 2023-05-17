import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  late bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();
  late List _predictions = [];

  @override
  void initState() {
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _loading = false;
      _predictions = prediction!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'ML Classifier',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/mask.png'),
            ),
            Container(
              child: Text(
                'ML Classifier',
                style: GoogleFonts.roboto(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  _loadimage_camera();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                //color: Colors.teal,
                child: Text(
                  'Camera',
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                //shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.circular(10))
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  _loadimage_gallery();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                //color: Colors.teal,
                child: Text(
                  'Gallery',
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                //shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.circular(10))
              ),
            ),
            _loading == false
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        Text(_predictions[0]['label'].toString().substring(2)),
                        Text('Confidence: ' +
                            _predictions[0]['confidence'].toString())
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
