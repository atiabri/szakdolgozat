import 'package:flutter/material.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart'; // Importáljuk a diagram könyvtárat

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

  // Színinterpolációs függvény a leglassabb és leggyorsabb sebesség alapján
  Color interpolateColor(double value, double min, double max) {
    if (max == min) return Colors.purple;
    double t = (value - min) / (max - min);
    return Color.lerp(Colors.blue, Colors.red, t)!; // Kék-piros interpoláció
  }

  @override
  Widget build(BuildContext context) {
    // Leggyorsabb és leglassabb sebesség értékek meghatározása
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
            // Kilométerenkénti sebesség oszlopdiagram
            SizedBox(
              height: 250, // Diagram mérete
              child: Center(
                // Középre igazítás
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        maxY: 8, // Y tengely maximuma 8 min/km
                        minY: 0, // Y tengely minimuma (min/km)
                        barGroups: List.generate(
                          entry.speedPerKm.length,
                          (index) => BarChartGroupData(
                            x: index, // X tengely érték (kilométerek)
                            barRods: [
                              BarChartRodData(
                                y: entry.speedPerKm[index], // Oszlop magassága
                                colors: [
                                  interpolateColor(entry.speedPerKm[index],
                                      minSpeed, maxSpeed)
                                ], // Interpolált színek
                                width:
                                    40, // Oszlop szélessége, hogy kitöltse a kilométert
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: SideTitles(
                              showTitles: false), // Felső címkék kikapcsolása
                          rightTitles: SideTitles(
                              showTitles:
                                  false), // Jobb oldali címkék kikapcsolása
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              // Kilométerek címkézése 1-től
                              return value.toInt() < 10
                                  ? '${value.toInt() + 1} km'
                                  : '';
                            },
                          ),
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              // Y tengelyen 0 és 8 között lévő értékek megjelenítése, min/km mértékegységgel
                              return '${value.toStringAsFixed(0)} min/km';
                            },
                            reservedSize: 60, // Hely biztosítása a címkézésnek
                          ),
                        ),
                        gridData:
                            FlGridData(show: true), // Rácsvonalak megjelenítése
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                        ), // Interakció bekapcsolása
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Diagram alatti rész
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
                        Icon(Icons.terrain,
                            color: Colors.purple), // Magasság ikon
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
