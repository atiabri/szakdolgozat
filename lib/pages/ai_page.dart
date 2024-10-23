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
  String _trainingPlan = ""; // Állapotváltozó az edzéstervhez

  @override
  void initState() {
    super.initState();
    _fitnessAI.loadModel();
    _initializeMessages();
    _loadUserData();
  }

  void _initializeMessages() {
    // Debugging: Kezdeti üzenet inicializálás
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

    // Debugging: Kezdeti üzenetek hozzáadása kész
    print("Initial messages added to the conversation.");
  }

  void _loadUserData() async {
    // Debugging: Jelezd, hogy elkezdődött az adatlekérdezés
    print("Fetching input data for userId: ${widget.userId}");

    List<double> inputData = await DB.getInputData(widget.userId);

    if (inputData.isNotEmpty) {
      // Debugging: Ha van adat, futtatjuk a predikciót
      print("Input data retrieved: $inputData");
      _makePrediction(inputData);
    } else {
      // Debugging: Nincs adat, hibaüzenet hozzáadása az üzenetlistához
      print("No input data found for user.");
      _addMessage("No input data found.", false);
    }
  }

  void _makePrediction(List<double> inputData) async {
    List<double> doubleInputData = inputData.map((d) => d.toDouble()).toList();

    // Debugging: Jelezd a konzolnak, hogy elkezdődött a predikció
    print("Running prediction with input data: $doubleInputData");

    // Fut a predikció, most várunk az eredményre
    List<dynamic> result = await _fitnessAI.predict(doubleInputData);

    // Debugging: Írd ki a predikció eredményét
    print("Prediction result: $result");

    double fitnessScore;
    if (result.isNotEmpty && result[0] != null) {
      fitnessScore = result[0];
    } else {
      // Debugging: Hibás eredmény, ezért alapértelmezett érték
      print(
          "No valid prediction result, setting fitnessScore to default (1.0)");
      fitnessScore = 1.0;
    }

    // Debugging: Fitness score ellenőrzés, ha nullát kapunk, akkor legalább 1.0 legyen
    if (fitnessScore == 0.0) {
      fitnessScore = 1.0;
    }

    // Debugging: Jelezd a számított fitness score-t
    print("Calculated fitness score: $fitnessScore");

    String trainingPlan = _generateTrainingPlan(fitnessScore);

    // Debugging: Jelezd, hogy most frissül az UI
    print("Updating UI with new training plan.");

    // Ellenőrizzük, hogy a widget még él-e, és frissítjük az UI-t
    if (mounted) {
      setState(() {
        print("UI state is being updated.");

        // Az UI frissítése, eltávolítjuk a második üzenetet és hozzáadjuk az újat
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
                  "Based on the analysis, I believe this training plan will be the most beneficial for you. I hope it serves you well!",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        );

        // Frissítjük az edzéstervet
        _trainingPlan = trainingPlan;
      });
    } else {
      // Debugging: Ha a widget már nem él, jelezd ezt a konzolba
      print("UI not mounted, state cannot be updated.");
    }
  }

  String _generateTrainingPlan(double fitnessScore) {
    String trainingPlan;

    if (fitnessScore < 25) {
      trainingPlan = 'Training Plan:\n\n'
          'Monday: 30 minutes of jogging\n'
          'Tuesday: Rest\n'
          'Wednesday: 30 minutes of cycling\n'
          'Thursday: Strength training for 30 minutes\n'
          'Friday: 20 minutes of yoga\n'
          'Saturday: Rest\n'
          'Sunday: 30 minutes of running\n';
    } else if (fitnessScore < 50) {
      trainingPlan = 'Training Plan:\n\n'
          'Monday: 40 minutes of jogging\n'
          'Tuesday: Strength training for 30 minutes\n'
          'Wednesday: 30 minutes of cycling\n'
          'Thursday: Rest\n'
          'Friday: 30 minutes of interval running\n'
          'Saturday: 20 minutes of yoga\n'
          'Sunday: 30 minutes of brisk walking\n';
    } else if (fitnessScore < 75) {
      trainingPlan = 'Training Plan:\n\n'
          'Monday: 45 minutes of running\n'
          'Tuesday: Strength training for 45 minutes\n'
          'Wednesday: 30 minutes of cycling\n'
          'Thursday: Rest\n'
          'Friday: 30 minutes of high-intensity interval training (HIIT)\n'
          'Saturday: 30 minutes of yoga\n'
          'Sunday: 1 hour of hiking\n';
    } else {
      trainingPlan = 'Training Plan:\n\n'
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
                // Itt jelenítjük meg az edzéstervet
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
                        _trainingPlan, // A trainingPlan itt jelenik meg
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
              // Debugging: Jelezd, hogy a frissítési gomb meg lett nyomva
              print(
                  "Refresh button pressed, reloading user data and running prediction.");

              // Frissítjük az adatokat és futtatjuk a predikciót
              _loadUserData();
            },
            child: Text('Refresh Prediction'),
          ),
        ],
      ),
    );
  }
}
