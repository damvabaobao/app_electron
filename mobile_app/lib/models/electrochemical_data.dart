class ElectrochemicalData {
  // ============================================================
  // COMMON DATA
  // ============================================================

  final double voltage;

  final double current;

  final DateTime timestamp;

  // ============================================================
  // TIME
  // Used mainly by Chronoamperometry (CA)
  // ============================================================

  final double? time;

  // ============================================================
  // EIS DATA
  // Used by Electrochemical Impedance Spectroscopy
  // ============================================================

  final double? frequency;

  final double? impedanceMagnitude;

  final double? phase;

  const ElectrochemicalData({
    required this.voltage,
    required this.current,
    required this.timestamp,

    this.time,
    this.frequency,
    this.impedanceMagnitude,
    this.phase,
  });
}
