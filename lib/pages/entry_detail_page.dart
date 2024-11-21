import 'package:flutter/material.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart'; // Libary for charts

class EntryDetailPage extends StatelessWidget {
  final Entry entry;

  EntryDetailPage({required this.entry});

  void _shareDetails() {
    final String content = '''
Run Details:
Date: ${entry.date}
Distance: ${(entry.distance / 1000).toStringAsFixed(2)} km
Duration: ${entry.duration}
Speed: ${entry.speed.toStringAsFixed(2)} min/km
Elevation Gain: ${entry.elevationGain.toStringAsFixed(2)} m
''';

    Share.share(content, subject: 'Run Details');
  }

  // Method for interpolation, regarding the min and max values
  Color interpolateColor(double value, double min, double max) {
    if (max == min) return Colors.purple;
    double t = (value - min) / (max - min);
    return Color.lerp(Colors.blue, Colors.red, t)!;
  }

  @override
  Widget build(BuildContext context) {
    double minSpeed = entry.speedPerKm.reduce((a, b) => a < b ? a : b);
    double maxSpeed = entry.speedPerKm.reduce((a, b) => a > b ? a : b);

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
            SizedBox(
              height: 250,
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        maxY: 8,
                        minY: 0,
                        barGroups: List.generate(
                          entry.speedPerKm.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                y: entry.speedPerKm[index],
                                colors: [
                                  interpolateColor(entry.speedPerKm[index],
                                      minSpeed, maxSpeed)
                                ],
                                width: 40,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: SideTitles(showTitles: false),
                          rightTitles: SideTitles(showTitles: false),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              return value.toInt() < 10
                                  ? '${value.toInt() + 1} km'
                                  : '';
                            },
                          ),
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              return '${value.toStringAsFixed(0)} min/km';
                            },
                            reservedSize: 60,
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                        Text('Speed: ${entry.speed.toStringAsFixed(2)} min/km',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.terrain, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                            'Elevation Gain: ${entry.elevationGain.toStringAsFixed(2)} m',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _shareDetails,
              child: Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(125, 69, 180, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
