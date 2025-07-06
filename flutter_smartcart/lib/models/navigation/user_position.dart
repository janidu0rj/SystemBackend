class UserPosition {
  final double x;
  final double y;
  final double z;

  UserPosition({required this.x, required this.y, required this.z});

  factory UserPosition.fromJson(Map<String, dynamic> json) {
    return UserPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'UserPosition(x: $x, y: $y, z: $z)';
}