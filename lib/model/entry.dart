class Entry {
  static String table = "entries";

  int? id;
  int userId;
  String date;
  String duration;
  double speed;
  double distance;
  List<double> speedPerKm; // Sebességek listája

  Entry({
    this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.speed,
    required this.distance,
    required this.speedPerKm, // Kilométerenkénti sebességek
  });

  // Map-á alakításkor a sebességek listáját vesszővel elválasztott string-gé alakítjuk
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date,
      'duration': duration,
      'speed': speed,
      'distance': distance,
      'speed_per_km':
          speedPerKm.join(','), // Lista elemeinek összefűzése vesszővel
    };
  }

  // Adatbázisból való visszaolvasáskor a string-et visszaalakítjuk listává
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
          .map((s) => double.parse(s))
          .toList(), // A string elemeit visszaalakítjuk double listává
    );
  }
}
