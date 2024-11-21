import 'package:flutter/material.dart';
import 'package:onlab_final/pages/home.dart';
import 'package:onlab_final/pages/login_page.dart';
import 'package:onlab_final/db/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init(); // Await initialization of the database
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LoginPage(),
    );
  }
}
