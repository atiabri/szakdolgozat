class Entry {
  static String table = "entries";

  int? id; // Make ID nullable
  int userId;
  String date;
  String duration;
  double speed;
  double distance;

  Entry({
    this.id, // ID is optional
    required this.userId,
    required this.date,
    required this.duration,
    required this.speed,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date,
      'duration': duration,
      'speed': speed,
      'distance': distance,
    };
  }

  static Entry fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'], // Map ID
      userId: map['user_id'],
      date: map['date'],
      duration: map['duration'],
      speed: map['speed'],
      distance: map['distance'],
    );
  }
}
