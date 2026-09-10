class MeasurementConfig {
  final String method;

  // ============================================================
  // VOLTAGE / SCAN PARAMETERS
  // ============================================================

  final double startVoltage;
  final double endVoltage;
  final double stepVoltage;
  final double scanRate;

  // ============================================================
  // GENERAL REPEAT
  // ============================================================

  final int cycles;

  // ============================================================
  // PULSE PARAMETERS
  // Used by DPV / SWV
  // ============================================================

  final double amplitude;
  final double pulseWidth;
  final double frequency;

  // ============================================================
  // FILTER
  // ============================================================

  final String filterType;

  // ============================================================
  // DEPOSITION
  // ============================================================

  final bool useDeposition;
  final double depositionVoltage;
  final int depositionTime;

  // ============================================================
  // CLEANING
  // Used by ASV
  // ============================================================

  final double cleaningVoltage;
  final int cleaningTime;

  // ============================================================
  // EQUILIBRIUM
  // Used by ASV
  // ============================================================

  final double equilibriumVoltage;
  final int equilibriumTime;

  // ============================================================
  // CHRONOAMPEROMETRY
  // ============================================================

  final int timeRun;
  final double appliedVoltage;
  final int timeInterval;

  // ============================================================
  // EIS
  // ============================================================

  final double startFrequency;
  final double stopFrequency;
  final int sweepPoints;
  final int repeatTimes;

  const MeasurementConfig({
    required this.method,

    // Voltage / scan
    required this.startVoltage,
    required this.endVoltage,
    required this.stepVoltage,
    required this.scanRate,

    // Repeat
    required this.cycles,

    // Pulse
    required this.amplitude,
    required this.pulseWidth,
    required this.frequency,

    // Filter
    required this.filterType,

    // Deposition
    required this.useDeposition,
    required this.depositionVoltage,
    required this.depositionTime,

    // Cleaning
    required this.cleaningVoltage,
    required this.cleaningTime,

    // Equilibrium
    required this.equilibriumVoltage,
    required this.equilibriumTime,

    // CA
    required this.timeRun,
    required this.appliedVoltage,
    required this.timeInterval,

    // EIS
    required this.startFrequency,
    required this.stopFrequency,
    required this.sweepPoints,
    required this.repeatTimes,
  });

  // ============================================================
  // DEFAULT CONFIG
  // ============================================================

  factory MeasurementConfig.defaults({String method = 'CV'}) {
    return MeasurementConfig(
      method: method,

      // Voltage / scan
      startVoltage: -200,
      endVoltage: 600,
      stepVoltage: 10,
      scanRate: 100,

      // Repeat
      cycles: 1,

      // Pulse
      amplitude: 25,
      pulseWidth: 50,
      frequency: 10,

      // Filter
      filterType: '1/7 (Moving Avg 7pt)',

      // Deposition
      useDeposition: false,
      depositionVoltage: -500,
      depositionTime: 60000,

      // Cleaning
      cleaningVoltage: 1100,
      cleaningTime: 8000,

      // Equilibrium
      equilibriumVoltage: -50,
      equilibriumTime: 10000,

      // CA
      timeRun: 30,
      appliedVoltage: 0,
      timeInterval: 100,

      // EIS
      startFrequency: 1,
      stopFrequency: 100000,
      sweepPoints: 50,
      repeatTimes: 1,
    );
  }
}
