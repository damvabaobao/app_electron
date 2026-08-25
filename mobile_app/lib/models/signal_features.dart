class SignalFeatures {
  final double meanCurrent;
  final double stdCurrent;
  final double maxCurrent;
  final double minCurrent;

  final double meanVoltage;
  final double voltageRange;

  final double meanGradient;
  final double maxGradient;
  final double minGradient;

  const SignalFeatures({
    required this.meanCurrent,
    required this.stdCurrent,
    required this.maxCurrent,
    required this.minCurrent,
    required this.meanVoltage,
    required this.voltageRange,
    required this.meanGradient,
    required this.maxGradient,
    required this.minGradient,
  });
}
