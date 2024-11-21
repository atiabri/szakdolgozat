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
  String _trainingPlan = "";
  double _fitnessScore = 0.0;

  @override
  void initState() {
    super.initState();
    _fitnessAI.loadModel();
    _initializeMessages();
    _loadUserData();
  }

  void _initializeMessages() {
    print("Initializing default AI conversation messages.");

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

    print("Initial messages added to the conversation.");
  }

  void _loadUserData() async {
    print("Fetching input data for userId: ${widget.userId}");

    List<double> inputData = await DB.getInputData(widget.userId);

    if (inputData.isNotEmpty) {
      print("Input data retrieved: $inputData");
      _makePrediction(inputData);
    } else {
      print("No input data found for user.");
      _addMessage("No input data found.", false);
    }
  }

  void _makePrediction(List<double> inputData) async {
    List<double> doubleInputData = inputData.map((d) => d.toDouble()).toList();

    print("Running prediction with input data: $doubleInputData");

    List<dynamic> result = await _fitnessAI.predict(doubleInputData);

    print("Prediction result: $result");

    double fitnessScore;
    if (result.isNotEmpty && result[0] != null) {
      fitnessScore = result[0];
    } else {
      print(
          "No valid prediction result, setting fitnessScore to default (1.0)");
      fitnessScore = 1.0;
    }

    if (fitnessScore == 0.0) {
      fitnessScore = 1.0;
    }

    print("Calculated fitness score: $fitnessScore");

    String trainingPlan = _generateTrainingPlan(fitnessScore);

    if (mounted) {
      setState(() {
        print("UI state is being updated.");

        _fitnessScore = fitnessScore;
        _fitnessScore = _fitnessScore > 100 ? 100 : _fitnessScore;
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
                  "Based on the analysis, I believe this training plan will be the most beneficial for you. Your fitness score is: ${_fitnessScore.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        );

        _trainingPlan = trainingPlan;
      });
    } else {
      print("UI not mounted, state cannot be updated.");
    }
  }

  String _generateTrainingPlan(double fitnessScore) {
    String trainingPlan;

    if (fitnessScore < 25) {
      trainingPlan = 'Beginner Level Training Plan:\n\n'
          'Monday: 15 minutes of brisk walking, 15 minutes of light stretching\n'
          'Tuesday: Rest\n'
          'Wednesday: 20 minutes of light yoga\n'
          'Thursday: 15 minutes of walking + 10 minutes of bodyweight exercises (e.g., squats, push-ups)\n'
          'Friday: Rest\n'
          'Saturday: 20 minutes of cycling at an easy pace\n'
          'Sunday: 30 minutes of walking in nature\n';
    } else if (fitnessScore < 50) {
      trainingPlan = 'Intermediate Level Training Plan:\n\n'
          'Monday: 20 minutes of jogging\n'
          'Tuesday: 30 minutes of bodyweight strength training (e.g., lunges, planks)\n'
          'Wednesday: 25 minutes of cycling\n'
          'Thursday: Rest\n'
          'Friday: 20 minutes of interval running (1 min jog, 1 min sprint, repeat)\n'
          'Saturday: 20 minutes of yoga or pilates\n'
          'Sunday: 40 minutes of brisk hiking\n';
    } else if (fitnessScore < 75) {
      trainingPlan = 'Advanced Level Training Plan:\n\n'
          'Monday: 30 minutes of steady-pace running\n'
          'Tuesday: 40 minutes of gym strength training (upper body focus)\n'
          'Wednesday: 30 minutes of cycling at moderate intensity\n'
          'Thursday: Rest or light recovery activity (e.g., yoga, stretching)\n'
          'Friday: 30 minutes of high-intensity interval training (HIIT)\n'
          'Saturday: 45 minutes of yoga with core focus\n'
          'Sunday: 60 minutes of trail running or outdoor sports\n';
    } else {
      trainingPlan = 'Elite Level Training Plan:\n\n'
          'Monday: 1 hour of running (moderate pace)\n'
          'Tuesday: 1 hour of gym strength training (full body focus)\n'
          'Wednesday: 45 minutes of cycling (mix of intervals and steady pace)\n'
          'Thursday: Active recovery (30 minutes of stretching or mobility work)\n'
          'Friday: 45 minutes of sprint interval training (e.g., 200m sprints, 90s rest)\n'
          'Saturday: 1 hour of yoga and flexibility exercises\n'
          'Sunday: 90 minutes of long-distance running or outdoor endurance sports\n';
    }

    return trainingPlan;
  }

  void _addMessage(String message, bool isUser) {
    setState(() {
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
              children: [
                ..._messages,
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
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
                        _trainingPlan,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print(
                  "Refresh button pressed, reloading user data and running prediction.");
              _loadUserData();
            },
            child: Text('Refresh Prediction'),
          ),
        ],
      ),
    );
  }
}
