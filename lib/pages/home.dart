import 'package:flutter/material.dart';
import 'package:onlab_final/db/db.dart';
import 'package:onlab_final/model/entry.dart';
import 'package:onlab_final/pages/maps.dart';
import 'package:onlab_final/widgets/entry_card.dart';
import 'package:onlab_final/pages/activity_chart.dart';
import 'package:onlab_final/pages/ai_page.dart';

class HomePage extends StatefulWidget {
  final int currentUserId; // Pass current user ID to HomePage

  HomePage({required Key key, required this.currentUserId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Entry> _data = [];
  int _selectedIndex = 0; // To track the current selected tab

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  void _addEntries(Entry en) async {
    print('A beszúrandó Entry objektum: ${en.toMap()}');
    int result = await DB.insert(Entry.table, en.toMap());
    print('Beszúrás eredménye: $result');
    _fetchEntries(); // Refresh entries after insertion
  }

  void _fetchEntries() async {
    print('Bejegyzések lekérdezése a user_id alapján: ${widget.currentUserId}');
    List<Map<String, dynamic>> _results =
        await DB.query(Entry.table, userId: widget.currentUserId);
    print('Lekérdezés eredménye: $_results');
    setState(() {
      _data = _results.map((item) => Entry.fromMap(item)).toList();
      print('Leképezett Entries objektumok: $_data');
    });
  }

  void _deleteEntry(int id) async {
    await DB.delete(Entry.table, id); // Delete from database
    _fetchEntries(); // Refresh entries after deletion
    print("Entry with ID $id deleted.");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityChartPage(userId: widget.currentUserId),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiPage(userId: widget.currentUserId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AtiRun"),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(125, 69, 180, 1),
      ),
      body: _selectedIndex == 0
          ? _data.isEmpty
              ? Center(child: Text("No entries yet"))
              : ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return EntryCard(
                      entry: _data[index],
                      onDelete: () {
                        if (_data[index].id != null) {
                          _deleteEntry(_data[index].id!);
                        } else {
                          print("Entry ID is null, cannot delete.");
                        }
                      },
                    );
                  },
                )
          : Container(), // Placeholder for other pages
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MapPage(userId: widget.currentUserId)),
        ).then((value) {
          if (value != null && value is Entry) {
            _addEntries(value);
          }
        }),
        tooltip: 'Add Run',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Activity Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(125, 69, 180, 1),
        onTap: _onItemTapped,
      ),
    );
  }
}
