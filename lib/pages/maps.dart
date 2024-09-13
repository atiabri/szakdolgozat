import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:onlab_final/model/entry.dart';

class MapPage extends StatefulWidget {
  final int userId; // Add this field

  MapPage({required this.userId}); // Add this parameter

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Polyline> polyline = {};
  Location _location = Location();
  late GoogleMapController _mapController;
  LatLng _center = const LatLng(0, 0);
  List<LatLng> route = [];

  double _dist = 0;
  late String _displayTime;
  late int _time;
  late int _lastTime;
  double _speed = 0;
  double _avgSpeed = 0;
  int _speedCounter = 0;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  void _requestLocationPermission() async {
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    double appendDist;

    print("Map created");

    _location.onLocationChanged.listen((event) {
      LatLng loc = LatLng(event.latitude!, event.longitude!);
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: loc, zoom: 15)));

      if (route.isNotEmpty) {
        appendDist = Geolocator.distanceBetween(route.last.latitude,
            route.last.longitude, loc.latitude, loc.longitude);
        setState(() {
          _dist += appendDist;
        });
      }

      setState(() {
        route.add(loc);
        polyline.add(Polyline(
            polylineId: PolylineId(route.toString()),
            points: route,
            color: Colors.blue,
            width: 3));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
            child: GoogleMap(
          polylines: polyline,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(target: _center, zoom: 11),
        )),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(10, 0, 10, 40),
              height: 150,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("SPEED (KM/H)",
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w300)),
                          Text(_speed.toStringAsFixed(2),
                              style: GoogleFonts.montserrat(
                                  fontSize: 30, fontWeight: FontWeight.w300))
                        ],
                      ),
                      Column(
                        children: [
                          Text("TIME",
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w300)),
                          StreamBuilder<int>(
                            stream: _stopWatchTimer.rawTime,
                            initialData: 0,
                            builder: (context, snap) {
                              _time = snap.data!;
                              _displayTime = StopWatchTimer.getDisplayTimeHours(
                                      _time) +
                                  ":" +
                                  StopWatchTimer.getDisplayTimeMinute(_time) +
                                  ":" +
                                  StopWatchTimer.getDisplayTimeSecond(_time);
                              return Text(_displayTime,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300));
                            },
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text("DISTANCE (KM)",
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w300)),
                          Text((_dist / 1000).toStringAsFixed(2),
                              style: GoogleFonts.montserrat(
                                  fontSize: 30, fontWeight: FontWeight.w300))
                        ],
                      )
                    ],
                  ),
                  Divider(),
                  IconButton(
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      size: 50,
                      color: Color.fromRGBO(125, 69, 180, 1),
                    ),
                    padding: EdgeInsets.all(0),
                    onPressed: () async {
                      // Create the new Entry object with user ID
                      Entry en = Entry(
                          date:
                              DateFormat.yMMMMd('en_US').format(DateTime.now()),
                          duration: _displayTime,
                          speed: (_dist / _time) * 10,
                          distance: _dist,
                          userId: widget.userId); // Pass user ID
                      Navigator.pop(context, en);
                    },
                  )
                ],
              ),
            ))
      ]),
    );
  }
}
