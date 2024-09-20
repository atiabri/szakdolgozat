import 'package:flutter/material.dart';
import 'package:onlab_final/db/db.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:onlab_final/pages/home.dart'; // Make sure this import is correct for your HomePage

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  key: Key(''),
                  currentUserId: widget.userId,
                ),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: _userEntries.isEmpty
            ? Text('Unfortunately, no activities recorded yet.')
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.75, // 60% of screen height
                  child: ScatterChart(
                    ScatterChartData(
                      minX: 0, // Minimum distance (km)
                      maxX: 40, // Maximum distance (km)
                      minY: 0, // Minimum speed (min/km)
                      maxY: 10, // Maximum speed (min/km)
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 10,
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
                          interval: 2,
                          getTitles: (value) {
                            return '${value.toInt()} min/km'; // Y-axis shows speed (min/km)
                          },
                          reservedSize: 40,
                          margin: 8,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          interval: 10,
                          getTitles: (value) {
                            return '${value.toInt()} km'; // X-axis shows distance (km)
                          },
                          reservedSize: 30,
                          margin: 8,
                          rotateAngle:
                              45, // Rotate the labels for better readability
                        ),
                        rightTitles: SideTitles(
                          showTitles: false, // Hide right titles
                        ),
                        topTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                      scatterSpots: _userEntries
                          .map(
                            (entry) => ScatterSpot(
                              entry.distance / 1000, // X-axis: distance in km
                              entry.speed, // Y-axis: speed in min/km
                              color: Colors.purple,
                              radius: 6,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
