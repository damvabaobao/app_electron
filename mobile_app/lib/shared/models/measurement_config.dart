class MeasurementConfig {
  final String method;

  final double startPotential;
  final double endPotential;
  final double scanRate;

  final int cycles;

  const MeasurementConfig({
    required this.method,
    required this.startPotential,
    required this.endPotential,
    required this.scanRate,
    required this.cycles,
  });

  @override
  String toString() {
    return '''
MeasurementConfig(method: $method, startPotential: $startPotential V, endPotential: $endPotential V, scanRate: $scanRate mV/s, cycles: $cycles,)
''';
  }
}
