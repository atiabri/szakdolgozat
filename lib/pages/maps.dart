import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:onlab_final/model/entry.dart';

class MapPage extends StatefulWidget {
  final int userId;

  MapPage({required this.userId});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Polyline> polyline = {};
  Location _location = Location();
  late GoogleMapController _mapController;
  LatLng _center = const LatLng(0, 0);
  List<LatLng> route = [];
  List<double> _speedsPerKm = []; // Kilométerenkénti sebességek

  double _dist = 0;
  double _kmCheckpoint = 0; // Kilométer checkpoint
  late String _displayTime;
  late int _time;
  double _avgSpeed = 0;

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

        // Kilométer ellenőrzés
        if (_dist / 1000 > _kmCheckpoint + 1) {
          _kmCheckpoint += 1;

          // Kilométerenkénti átlagsebesség kiszámítása és hozzáadása a listához
          double currentAvgSpeed = _calculateCurrentAvgSpeed();
          _speedsPerKm.add(currentAvgSpeed);
        }
      }

      setState(() {
        route.add(loc);
        polyline.add(Polyline(
            polylineId: PolylineId(route.toString()),
            points: route,
            color: Colors.blue,
            width: 3));
      });

      // Átlagsebesség frissítése
      _updateAverageSpeed();
    });
  }

  // Kilométerenkénti átlagsebesség kiszámítása (min/km)
  double _calculateCurrentAvgSpeed() {
    if (_time > 0 && _dist > 0) {
      double timeInMinutes = _time / (1000 * 60);
      double distanceInKm = _dist / 1000;
      return timeInMinutes / distanceInKm;
    }
    return 0;
  }

  void _updateAverageSpeed() {
    if (_dist > 0 && _time > 0) {
      double timeInMinutes = _time / (1000 * 60);
      double distanceInKm = _dist / 1000;
      _avgSpeed = timeInMinutes / distanceInKm;
    } else {
      _avgSpeed = 0;
    }
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
                          Text("AVG SPEED (MIN/KM)",
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w300)),
                          Text(
                              _avgSpeed > 0
                                  ? _avgSpeed.toStringAsFixed(2)
                                  : "--",
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
                      // Entry objektum létrehozása és mentése
                      Entry en = Entry(
                          date:
                              DateFormat.yMMMMd('en_US').format(DateTime.now()),
                          duration: _displayTime,
                          speed: _avgSpeed, // Átlagsebesség (min/km)
                          distance: _dist,
                          speedPerKm:
                              _speedsPerKm, // Kilométerenkénti sebességek
                          userId: widget.userId); // User ID hozzáadása
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
