class Entry {
  static String table = "entries";

  int? id;
  int userId;
  String date;
  String duration;
  double speed;
  double distance;
  double elevationGain;
  List<double> speedPerKm;

  Entry({
    this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.speed,
    required this.distance,
    required this.elevationGain,
    required this.speedPerKm,
  });

// Convert an Entry object to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date,
      'duration': duration,
      'speed': speed,
      'distance': distance,
      'elevation_gain': elevationGain ?? 0.0,
      'speed_per_km': speedPerKm.join(','),
    };
  }

  // Convert a Map to an Entry object
  static Entry fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      userId: map['user_id'],
      date: map['date'],
      duration: map['duration'],
      speed: map['speed'],
      distance: map['distance'],
      elevationGain:
          map['elevation_gain'] != null ? map['elevation_gain'] : 0.0,
      speedPerKm: (map['speed_per_km'] as String)
          .split(',')
          .map((s) => double.parse(s))
          .toList(),
    );
  }
}
