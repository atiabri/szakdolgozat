import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:onlab_final/pages/entry_detail_page.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onDelete;

  EntryCard({required this.entry, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Navigating to EntryDetailPage");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntryDetailPage(entry: entry),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5, // Kiemelkedés (árnyék)
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Felső sor: dátum és távolság
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.date,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "${(entry.distance / 1000).toStringAsFixed(2)} km",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Alsó sor: időtartam és sebesség
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 18, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        entry.duration,
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.speed, size: 18, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        "${entry.speed.toStringAsFixed(2)} min/km", // "perc/km" -> "min/km"
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              if (onDelete != null) // Törlés gomb, ha onDelete nem null
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 20,
                ),
              if (onDelete != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      "Delete", // "Törlés" -> "Delete"
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
