class Entry {
  static String table = "entries";

  int? id;
  int userId;
  String date;
  String duration;
  double speed;
  double distance;
  List<double> speedPerKm; // Új mező a kilométerenkénti sebességekhez

  Entry({
    this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.speed,
    required this.distance,
    required this.speedPerKm, // Új mező inicializálása
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date,
      'duration': duration,
      'speed': speed,
      'distance': distance,
      'speed_per_km':
          speedPerKm.join(','), // Sebességek listáját szövegként tároljuk
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
      speedPerKm: (map['speed_per_km'] as String)
          .split(',')
          .map((e) => double.parse(e))
          .toList(), // Listává alakítjuk a szöveget
    );
  }
}
