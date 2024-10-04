class Entry {
  static String table = "entries";

  int? id;
  int userId;
  String date;
  String duration;
  double speed;
  double distance;
  double elevationGain; // Új mező a szintkülönbséghez
  List<double> speedPerKm;

  Entry({
    this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.speed,
    required this.distance,
    required this.elevationGain, // Új mező inicializálása
    required this.speedPerKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date,
      'duration': duration,
      'speed': speed,
      'distance': distance,
      'elevation_gain': elevationGain, // Szintkülönbség tárolása
      'speed_per_km': speedPerKm.join(','),
    };
  }

  static Entry fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      userId: map['user_id'],
      date: map['date'],
      duration: map['duration'],
      speed: map['speed'],
      distance: map['distance'],
      elevationGain: map['elevation_gain'], // Szintkülönbség visszaállítása
      speedPerKm: (map['speed_per_km'] as String)
          .split(',')
          .map((e) => double.parse(e))
          .toList(),
    );
  }
}
