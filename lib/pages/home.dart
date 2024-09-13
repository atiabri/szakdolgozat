import 'package:flutter/material.dart';
import 'package:onlab_final/db/db.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:onlab_final/pages/maps.dart';
import 'package:onlab_final/widgets/entry_card.dart';

class HomePage extends StatefulWidget {
  final int currentUserId; // Pass current user ID to HomePage

  HomePage({required Key key, required this.currentUserId}) : super(key: key);

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

  // Fetch run entries filtered by user ID
  void _fetchEntries() async {
    List<Map<String, dynamic>> _results = await DB.query(Entry.table,
        userId: widget.currentUserId); // Filter by current user's ID
    setState(() {
      _data = _results.map((item) => Entry.fromMap(item)).toList();
    });
  }

  // Add a new entry and refresh the list
  void _addEntries(Entry en) async {
    await DB.insert(Entry.table, en.toMap());
    _fetchEntries(); // Refresh entries
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
                return EntryCard(entry: _data[index]); // Display entry card
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MapPage(
                  userId: widget.currentUserId)), // Pass current user ID
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
