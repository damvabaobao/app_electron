import numpy as np

FEATURE_NAME = [ "meanCurrent", "stdCurrent", "maxCurrent", "minCurrent", "meanVoltage", "voltageRange", "meanGradient", "maxGradient", "minGradient", "peakCurrent", "peakPotential", "peakWidth", "peakArea", "peakProminence", "peakSymmetry",]

def validate_input(voltage, current) :
        # Kiem tra du lieu dau vao
        voltage = np.asarry(voltage, dtype = float)
        current = np.asarray(current, dtype=float)

        if voltage.ndim != 1 or current.ndim != 1:
                raise ValueError("Voltage va current phai la mang 1 chieu")
        if len(voltage) != len(current):
                raise ValueError("Voltage va current phao co cung so diem")
        if len(voltage) < 5:
                raise ValueError("Can it nhat 5 diem du lieu")
        if not np.all(np.isfinite(voltage)):
                raise ValueError("Voltage chua gia tri khong hop le")
        if not np.all(np.isfinite(current)):
                raise ValueError("Current chua gia tri khong hop le")
        return voltage, current

def calculate_basic_features(voltage, current):
        # Tinh cac feature thong ke co ban
        features ={}
        features["meanCurrent"] = float(np.mean(current))
        features["stdCurrent"] = float(np.std(current))
        features["maxCurrent"] = float(np.max(current))
        features["minCurrent"] = float(np.min(current))
        features["meanVoltage"] = float(np.mean(voltage))
        features["voltageRange"] = float(np.max(voltage) - np.min(voltage))

        return features

def calculate_gradient_features(voltage, current):
        # Tinh gradient cua dong dien theo dien the

        gradient = np.gradient(current, voltage)
        features = {}
        features["meanGradient"] = float (np.mean(gradient))
        features["maxGradient"] = float(np.max(gradient))
        features["voltageRange"] = float(np.max(voltage) - np.min(voltage))
        return features


