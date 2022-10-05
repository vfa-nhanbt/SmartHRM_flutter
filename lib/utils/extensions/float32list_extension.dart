import 'dart:typed_data';

extension castFloat32List on List<Object?> {
  Float32List toFloat32List() {
    final List<double> doubles = this.cast<double>();

    return Float32List.fromList(doubles);
  }
}

extension castMapObject on Map<Object?, Object?> {
  Map<String, int> toMapInt() {
    return this.cast<String, int>();
  }
}
