class FeatureVector {
  final List<double> values;

  const FeatureVector({required this.values});

  int get length => values.length;

  double operator [](int index) => values[index];

  List<double> toList() {
    return List.unmodifiable(values);
  }
}
