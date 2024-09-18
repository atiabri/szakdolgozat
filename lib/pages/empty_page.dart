import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empty Page'),
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('This is an empty page.'),
      ),
    );
  }
}
