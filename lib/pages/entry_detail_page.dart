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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${entry.date}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Distance: ${(entry.distance / 1000).toStringAsFixed(2)} km',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Duration: ${entry.duration}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Speed: ${entry.speed.toStringAsFixed(2)} perc/km',
                style: TextStyle(fontSize: 20)),
            // Itt további adatok jeleníthetők meg a futásról
          ],
        ),
      ),
    );
  }
}
