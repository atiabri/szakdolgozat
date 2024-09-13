import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:onlab_final/pages/entry_detail_page.dart'; // Hozd létre ezt az oldalt

class EntryCard extends StatelessWidget {
  final Entry entry;
  EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigálás a részletes oldalra a kártyára való kattintáskor
        print("Navigating to EntryDetailPage");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntryDetailPage(entry: entry),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.date, style: GoogleFonts.montserrat(fontSize: 18)),
                  Text((entry.distance / 1000).toStringAsFixed(2) + " km",
                      style: GoogleFonts.montserrat(fontSize: 18)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.duration,
                      style: GoogleFonts.montserrat(fontSize: 14)),
                  Text(entry.speed.toStringAsFixed(2) + " perc/km",
                      style: GoogleFonts.montserrat(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
