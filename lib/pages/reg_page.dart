import 'package:flutter/material.dart';
import 'package:onlab_final/pages/home.dart';
import 'package:onlab_final/model/user.dart';
import 'package:onlab_final/db/db.dart';
import 'package:sqflite/sqflite.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  String? gender;
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String? level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reduce spacing above the first field
            SizedBox(height: 20),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: birthdateController,
              decoration: InputDecoration(labelText: 'Birthdate (yyyy-mm-dd)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Wrap Gender and Level in a Row for horizontal alignment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Gender'),
                    value: gender,
                    isExpanded: true, // Make it fill the available space
                    items:
                        <String>['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        gender = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16), // Add spacing between the two dropdowns
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Level'),
                    value: level,
                    isExpanded: true, // Make it fill the available space
                    items: <String>['Beginner', 'Intermediate', 'Advanced']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        level = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _registerUser() async {
    try {
      DateTime birthDate = DateTime.parse(birthdateController.text);
      double height = double.parse(heightController.text);
      double weight = double.parse(weightController.text);

      final Database db = await DB.getDatabase();
      User newUser = User(
        fullName: fullNameController.text,
        username: usernameController.text,
        password: passwordController.text,
        birthDate: birthDate,
        gender: gender ?? '',
        height: height,
        weight: weight,
        level: level ?? 'Beginner',
      );

      await User.insertUser(db, newUser);

      User? createdUser = await User.getUserByUsername(db, newUser.username);
      if (createdUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              key: Key(''),
              currentUserId: createdUser.id!,
            ),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Failed"),
            content: Text("Please enter valid data."),
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
  }
}
