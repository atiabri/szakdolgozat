import 'package:flutter/material.dart';
import 'package:onlab_final/db/db.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:onlab_final/pages/maps.dart';
import 'package:onlab_final/widgets/entry_card.dart';

class HomePage extends StatefulWidget {
  HomePage({required Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Entry> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  // A futások adatainak lekérdezése és a lista frissítése
  void _fetchEntries() async {
    List<Map<String, dynamic>> _results = await DB.query(Entry.table);
    setState(() {
      _data = _results.map((item) => Entry.fromMap(item)).toList();
    });
  }

  // Új futás hozzáadása és az adatok frissítése
  void _addEntries(Entry en) async {
    await DB.insert(Entry.table, en.toMap());
    _fetchEntries(); // Újra lekéri az adatokat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AtiRun"),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
      ),
      body: _data.isEmpty
          ? Center(child: Text("No entries yet"))
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return EntryCard(entry: _data[index]); // Kártya megjelenítése
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapPage()),
        ).then((value) {
          if (value != null && value is Entry) {
            _addEntries(value);
          }
        }),
        tooltip: 'Add Run',
        child: Icon(Icons.add),
      ),
    );
  }
}
