import 'package:flutter/material.dart';
import 'fitness_ai.dart';
import 'package:onlab_final/db/db.dart';

class AiPage extends StatefulWidget {
  final int userId;

  AiPage({required this.userId});

  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final FitnessAI _fitnessAI = FitnessAI();
  List<Widget> _messages = [];

  @override
  void initState() {
    super.initState();
    print("Initializing AI page for user ID: ${widget.userId}"); // Debug
    _fitnessAI.loadModel();
    _initializeMessages();
    _loadUserData();
  }

  void _initializeMessages() {
    _messages.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
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
            constraints: BoxConstraints(maxWidth: 250),
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

  void _loadUserData() async {
    print("Loading user data for user ID: ${widget.userId}"); // Debug
    List<double> inputData = await DB.getInputData(widget.userId);
    print("Input Data: $inputData"); // Debug

    if (inputData.isNotEmpty) {
      _makePrediction(inputData);
    } else {
      print("No input data available for user ID: ${widget.userId}"); // Debug
      _addMessage("No input data found.", false);
    }
  }

  void _makePrediction(List<double> inputData) {
    print("Making prediction with input data: $inputData"); // Debug
    List<dynamic> result = _fitnessAI.predict(inputData);
    double fitnessScore = result[0];
    print("Predicted Fitness Score: $fitnessScore"); // Debug

    String trainingPlan = _generateTrainingPlan(fitnessScore);

    _addMessage(trainingPlan, false);

    if (fitnessScore > 0) {
      print("Valid fitness score found, updating AI message."); // Debug
      setState(() {
        _messages.removeAt(1);
        _messages.insert(
          1,
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: 250),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "Here is your recommended training plan based on your fitness level!",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        );
      });
    } else {
      print(
          "Fitness score is zero or negative, not updating AI message."); // Debug
    }
  }

  String _generateTrainingPlan(double fitnessScore) {
    print(
        "Generating training plan based on fitness score: $fitnessScore"); // Debug
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

    print("Generated training plan: $trainingPlan"); // Debug
    return trainingPlan;
  }

  void _addMessage(String message, bool isUser) {
    setState(() {
      print("Adding message: $message, isUser: $isUser"); // Debug
      _messages.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: 250),
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
    print("Disposing FitnessAI instance."); // Debug
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
