class MeasurementConfig {
  final String method;
  final double startVoltage;
  final double endVoltage;
  final double scanRate;
  final int cycles;

  const MeasurementConfig({
    required this.method,
    required this.startVoltage,
    required this.endVoltage,
    required this.scanRate,
    required this.cycles,
  });
}
