import 'dart:ffi';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FitnessAI {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      print('Loading AI model...'); // Debug
      _interpreter = await Interpreter.fromAsset('fitness_level_model.tflite');
      print('Model successfully loaded.'); // Debug
    } catch (e) {
      print('Error loading model: $e'); // Debug
    }
  }

  List<dynamic> predict(List<double> inputData) {
    print('Running AI prediction...'); // Debug
    if (inputData.length != 8) {
      print(
          'Invalid input data length. Expected 8, but got ${inputData.length}');
      throw Exception('Input data must have exactly 8 elements.');
    }

    var input = TensorBuffer.createFixedSize([1, 8], TfLiteType.float32);
    input.loadList(inputData, shape: [1, 8]);

    var output = TensorBuffer.createFixedSize([1, 1], TfLiteType.float32);

    try {
      _interpreter?.run(input.buffer, output.buffer);
      print('Prediction successful.'); // Debug
    } catch (e) {
      print('Error during prediction: $e');
      return [0.0];
    }

    return output.getDoubleList();
  }

  void dispose() {
    print('Disposing interpreter...'); // Debug
    _interpreter?.close();
  }
}
