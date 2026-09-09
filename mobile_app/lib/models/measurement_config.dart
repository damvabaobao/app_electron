class MeasurementConfig {
  final String method;

  // Common parameters
  final double startVoltage;
  final double endVoltage;
  final double stepVoltage;
  final double scanRate;
  final int cycles;

  // DPV / SWV
  final double amplitude;
  final double pulseWidth;
  final double frequency;

  // ASV
  final bool useDeposition;
  final double depositionVoltage;
  final int depositionTime;

  final double cleaningVoltage;
  final int cleaningTime;

  final double equilibriumVoltage;
  final int equilibriumTime;

  // Signal processing
  final String filterType;

  const MeasurementConfig({
    required this.method,

    required this.startVoltage,
    required this.endVoltage,
    required this.stepVoltage,
    required this.scanRate,
    required this.cycles,

    required this.amplitude,
    required this.pulseWidth,
    required this.frequency,

    required this.useDeposition,
    required this.depositionVoltage,
    required this.depositionTime,

    required this.cleaningVoltage,
    required this.cleaningTime,

    required this.equilibriumVoltage,
    required this.equilibriumTime,

    required this.filterType,
  });
}
