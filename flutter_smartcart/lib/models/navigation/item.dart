class Item {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'row': row,
      'col': col,
      'index': index,
    };
  }
  final String id;
  final String name;
  final int row;
  final int col;
  final int index;

  Item({
    required this.id,
    required this.name,
    required this.row,
    required this.col,
    required this.index,
  });
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      row: json['row'],
      col: json['col'],
      index: json['index'],
    );
  }

  @override
  String toString() {
    return '{name: $name, id: $id, row: $row, col: $col, index: $index}';
  }
}