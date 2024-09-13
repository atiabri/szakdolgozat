import 'package:flutter/material.dart';
import 'package:onlab_final/model/entry.dart';

class EntryDetailPage extends StatelessWidget {
  final Entry entry;

  EntryDetailPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Run Details'),
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Date: ${entry.date}',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.directions_run, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                            'Distance: ${(entry.distance / 1000).toStringAsFixed(2)} km',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Duration: ${entry.duration}',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Speed: ${entry.speed.toStringAsFixed(2)} perc/km',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    // Add more information blocks here if needed
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Optionally, add a section for the map or screenshot of the run route here
          ],
        ),
      ),
    );
  }
}
