import 'package:flutter/material.dart';
import 'fitness_ai.dart';
import 'package:onlab_final/db/db.dart';

class AiPage extends StatefulWidget {
  final int userId; // userID fogadása az AiPage-ben

  AiPage({required this.userId}); // Konstruktor, amely fogadja a userID-t

  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final FitnessAI _fitnessAI = FitnessAI();
  List<Widget> _messages = []; // List to hold chat messages

  @override
  void initState() {
    super.initState();
    _fitnessAI.loadModel();
    _initializeMessages(); // Initialize messages with default values
    _loadUserData(); // Felhasználói adatok betöltése
  }

  // Initialize default chat messages
  void _initializeMessages() {
    _messages.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: 250), // Narrower user message
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              "What kind of training plan do you recommend for me?",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );

    _messages.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 250), // Narrower AI message
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              "Please record more activities in order to provide a more accurate analysis of your fitness level and training recommendations.",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  // Felhasználói adatok lekérdezése és AI futtatása
  void _loadUserData() async {
    List<double> inputData =
        await DB.getInputData(widget.userId); // Statikus hívás
    print("Input Data: $inputData"); // Debug statement

    if (inputData.isNotEmpty) {
      _makePrediction(inputData);
    } else {
      _addMessage("No input data found.", false);
    }
  }

  // AI predikció készítése és edzésterv generálása
  void _makePrediction(List<double> inputData) {
    List<dynamic> result = _fitnessAI.predict(inputData);
    double fitnessScore = result[0];
    print("Predicted Fitness Score: $fitnessScore"); // Debug statement

    String trainingPlan = _generateTrainingPlan(fitnessScore);

    // Add AI response with the generated training plan
    _addMessage(trainingPlan, false);
  }

  // Edzésterv generálása a fitness pontszám alapján
  String _generateTrainingPlan(double fitnessScore) {
    String trainingPlan;

    if (fitnessScore < 25) {
      trainingPlan = 'Training Plan (0-25 Points):\n\n'
          'Monday: 30 minutes of brisk walking\n'
          'Tuesday: Rest\n'
          'Wednesday: 30 minutes of light stretching\n'
          'Thursday: Rest\n'
          'Friday: 20 minutes of yoga\n'
          'Saturday: Rest\n'
          'Sunday: 30 minutes of walking\n';
    } else if (fitnessScore < 50) {
      trainingPlan = 'Training Plan (25-50 Points):\n\n'
          'Monday: 40 minutes of jogging\n'
          'Tuesday: Strength training for 30 minutes\n'
          'Wednesday: 30 minutes of cycling\n'
          'Thursday: Rest\n'
          'Friday: 30 minutes of interval running\n'
          'Saturday: 20 minutes of yoga\n'
          'Sunday: 30 minutes of brisk walking\n';
    } else if (fitnessScore < 75) {
      trainingPlan = 'Training Plan (50-75 Points):\n\n'
          'Monday: 45 minutes of running\n'
          'Tuesday: Strength training for 45 minutes\n'
          'Wednesday: 30 minutes of cycling\n'
          'Thursday: Rest\n'
          'Friday: 30 minutes of high-intensity interval training (HIIT)\n'
          'Saturday: 30 minutes of yoga\n'
          'Sunday: 1 hour of hiking\n';
    } else {
      trainingPlan = 'Training Plan (75-100 Points):\n\n'
          'Monday: 1 hour of running\n'
          'Tuesday: Strength training for 1 hour\n'
          'Wednesday: 45 minutes of cycling\n'
          'Thursday: Rest or light activity\n'
          'Friday: 30 minutes of sprinting drills\n'
          'Saturday: 45 minutes of yoga and flexibility training\n'
          'Sunday: 1 hour of hiking or outdoor sports\n';
    }

    return trainingPlan;
  }

  // Method to add messages to the chat
  void _addMessage(String message, bool isUser) {
    setState(() {
      _messages.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: 250), // Adjust width for both messages
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fitnessAI.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Fitness Prediction'),
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _messages,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUserData,
            child: Text('Refresh Prediction'),
          ),
        ],
      ),
    );
  }
}
