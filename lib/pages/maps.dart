import 'dart:async';
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
  List<double> _speedsPerKm = [];
  double _dist = 0;
  double _kmCheckpoint = 0;
  late String _displayTime;
  late int _time;
  double _avgSpeed = 0;
  double _elevationGain = 0;
  double? _previousAltitude;
  bool _isPaused = false;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  Timer? _locationTimer;
  int _lastCheckpointTime = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    _locationTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      if (!_isPaused) {
        LocationData currentLocation = await _location.getLocation();
        _updateLocation(currentLocation);
      }
    });
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

  void _updateLocation(LocationData event) {
    LatLng loc = LatLng(event.latitude!, event.longitude!);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: loc, zoom: 15),
    ));

    if (route.isNotEmpty) {
      double appendDist = Geolocator.distanceBetween(
        route.last.latitude,
        route.last.longitude,
        loc.latitude,
        loc.longitude,
      );
      setState(() {
        _dist += appendDist;
      });

      if (_dist / 1000 > _kmCheckpoint) {
        _kmCheckpoint += 1;

        int elapsedTimeForKm = _time - _lastCheckpointTime;
        double speedForKm = elapsedTimeForKm / 60000.0;
        _speedsPerKm.add(speedForKm);

        _lastCheckpointTime = _time;
      }

      if (_previousAltitude != null && event.altitude != null) {
        double altitudeChange = event.altitude! - _previousAltitude!;
        if (altitudeChange > 0) {
          _elevationGain += altitudeChange;
        }
      }
    }

    _previousAltitude = event.altitude;
    setState(() {
      route.add(loc);
      polyline.add(Polyline(
        polylineId: PolylineId(route.toString()),
        points: route,
        color: Colors.blue,
        width: 3,
      ));
    });
    _updateAverageSpeed();
  }

  void _calculateRemainingSpeed() {
    if (_dist % 1000 > 0) {
      double remainingDistance = _dist % 1000;
      int elapsedTimeSinceLastCheckpoint = _time - _lastCheckpointTime;

      if (elapsedTimeSinceLastCheckpoint > 0) {
        double speedForRemaining = (elapsedTimeSinceLastCheckpoint / 60000.0) /
            (remainingDistance / 1000);
        _speedsPerKm.add(speedForRemaining);
      }
    }
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

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      } else {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            polylines: polyline,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(target: _center, zoom: 11),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  height: 150,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("AVG SPEED (MIN/KM)",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300)),
                                Text(
                                    _avgSpeed > 0
                                        ? _avgSpeed.toStringAsFixed(2)
                                        : "--",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w300))
                              ],
                            ),
                            Column(
                              children: [
                                Text("TIME",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300)),
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: 0,
                                  builder: (context, snap) {
                                    _time = snap.data!;
                                    _displayTime =
                                        StopWatchTimer.getDisplayTime(_time,
                                            hours: false, milliSecond: false);
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300)),
                                Text((_dist / 1000).toStringAsFixed(2),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w300))
                              ],
                            )
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pause Button with purple circle background
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(125, 69, 180, 1),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isPaused ? Icons.play_arrow : Icons.pause,
                                  color: Colors.white,
                                ),
                                iconSize: 40,
                                onPressed: _togglePause,
                              ),
                            ),
                            // Stop Button with purple circle background
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(125, 69, 180, 1),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                ),
                                iconSize: 40,
                                onPressed: () async {
                                  print(
                                      'Kilométerenkénti sebességek: $_speedsPerKm');
                                  print('Teljes távolság: $_dist');
                                  print('Átlagos sebesség: $_avgSpeed');
                                  print('Idő kijelző: $_displayTime');
                                  List<double> emergency = [0.0];
                                  Entry en = Entry(
                                    date: DateFormat.yMMMMd('en_US')
                                        .format(DateTime.now()),
                                    duration: _displayTime,
                                    speed: _avgSpeed,
                                    distance: _dist,
                                    elevationGain: _elevationGain,
                                    speedPerKm:
                                        _dist > 1 ? _speedsPerKm : emergency,
                                    userId: widget.userId,
                                  );
                                  print(
                                      'Létrehozott Entry objektum: ${en.toMap()}');
                                  Navigator.pop(context, en);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }
}
