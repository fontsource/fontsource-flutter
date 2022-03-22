import 'package:flutter/material.dart';
import 'package:fontsource/fontsource.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Sphinx of black quartz, judge my vow.',
                style:
                    FontsourceTextStyle(fontFamily: 'Alex Brush', fontSize: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
