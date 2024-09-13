import 'package:flutter/material.dart';
import 'package:onlab_final/pages/home.dart';
import 'package:onlab_final/pages/reg_page.dart'; // Updated import for RegisterPage
import 'package:onlab_final/model/user.dart';
import 'package:onlab_final/db/db.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final Database db = await DB
                    .getDatabase(); // Use the public method to get the database
                String username = usernameController.text;
                String password = passwordController.text;

                // Query the user by username
                User? user = await User.getUserByUsername(db, username);

                if (user != null && user.password == password) {
                  // Successful login, navigate to home page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(key: Key(''))));
                } else {
                  // Handle login error (e.g., show a dialog)
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Login Failed"),
                        content: Text("Incorrect username or password"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('No account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
