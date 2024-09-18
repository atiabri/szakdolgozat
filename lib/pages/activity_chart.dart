import 'package:flutter/material.dart';
import 'package:onlab_final/db/db.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChartPage extends StatefulWidget {
  final int userId;

  ActivityChartPage({required this.userId});

  @override
  _ActivityChartPageState createState() => _ActivityChartPageState();
}

class _ActivityChartPageState extends State<ActivityChartPage> {
  List<Entry> _userEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchUserActivities();
  }

  // Fetch the user's activities from the database
  void _fetchUserActivities() async {
    List<Map<String, dynamic>> results =
        await DB.query(Entry.table, userId: widget.userId);
    setState(() {
      _userEntries = results.map((item) => Entry.fromMap(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Chart'),
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _userEntries.isEmpty
            ? Text('Unfortunately, no activities recorded yet.')
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScatterChart(
                  ScatterChartData(
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 20,
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      horizontalInterval: 5,
                      verticalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitles: (value) {
                          return '${value.toInt()} km';
                        },
                        reservedSize: 40,
                        margin: 8,
                      ),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        interval: 2, // Adjust interval to reduce clutter
                        getTitles: (value) {
                          return '${value.toInt()} min/km';
                        },
                        reservedSize: 30,
                        margin: 8,
                        rotateAngle:
                            45, // Rotate the labels for better readability
                      ),
                    ),
                    scatterSpots: _userEntries
                        .map(
                          (entry) => ScatterSpot(
                            entry.speed, // x-axis: speed in minutes per km
                            entry.distance / 1000, // y-axis: distance in km
                            color: Colors.purple,
                            radius: 6,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
