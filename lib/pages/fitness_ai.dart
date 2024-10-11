import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FitnessAI {
  Interpreter? _interpreter;

  // A modell betöltése
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('fitness_level_model.tflite');
      print('Model successfully loaded.');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  // Prediction metódus, amely bemeneti adatokat és fitness pontszámot ad vissza
  List<dynamic> predict(List<dynamic> inputData) {
    // Input validálása
    if (inputData.length != 5) {
      throw Exception('Input data must have exactly 5 elements.');
    }

    var input = TensorBuffer.createFixedSize([1, 5], TfLiteType.float32);

    // Providing shape argument to loadList
    input.loadList(inputData, shape: [1, 5]);

    var output = TensorBuffer.createFixedSize([1, 1], TfLiteType.float32);

    // Futtatjuk a predikciót
    try {
      _interpreter?.run(input.buffer, output.buffer);
    } catch (e) {
      print('Error during prediction: $e');
      return [0.0]; // Returning a default value on error
    }

    // Eredmény lekérése
    return output.getDoubleList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
