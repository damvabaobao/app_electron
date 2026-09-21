import numpy as np

FEATURE_NAME = [ "meanCurrent", "stdCurrent", "maxCurrent", "minCurrent", "meanVoltage", "voltageRange", "meanGradient", "maxGradient", "minGradient", "peakCurrent", "peakPotential", "peakWidth", "peakArea", "peakProminence", "peakSymmetry",]

def validate_input(voltage, current) :
        # Kiem tra du lieu dau vao
        voltage = np.asarray(voltage, dtype = float)
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
        

        gradient = np.gradient(current)
        features = {"meanGradient": float(np.mean(gradient)),
                    "maxGradient": float(np.max(gradient)),
                    "minGradient": float(np.min(gradient)),}
        return features, gradient

def find_main_peak(voltage, current):
        #Tim peak dua tren do lech khoi baseline

        baseline = np.median(current)
        deviation = current - baseline
        peak_index = int(np.argmax(np.abs(deviation)))
        peak_current = float(current[peak_index])
        peak_potential = float(voltage[peak_index])

        return peak_index, peak_current, peak_potential, baseline, deviation

def calculate_peak_width(voltage, deviation, peak_index):
        #Uoc luong peak bang phuong pha half-prominece

        peak_value = deviation[peak_index]
        peak_abs = abs(peak_value)
        if peak_abs <= 0:
                return 0.0

        half_level = peak_abs * 0.5
        abs_deviation = np.abs(deviation)
        left_index = peak_index

        while left_index > 0:
                if abs_deviation[left_index] < half_level:
                        break
                left_index -= 1

        right_index = peak_index

        while right_index < len(abs_deviation) - 1:
                if abs_deviation[right_index] < half_level:
                        break
                right_index += 1

        width = abs(voltage[right_index] - voltage[left_index])
        return float(width)

def calculate_peak_area(voltage, deviation, peak_index):
        #Tinh dien tich tuyet doi quanh peak chinh

        peak_abs = abs(deviation[peak_index])
        if peak_abs <= 0:
                return 0.0
        
        half_level = peak_abs * 0.5
        abs_deviation = np.abs(deviation)
        left_index = peak_index
        while left_index > 0:
                if abs_deviation[left_index] < half_level:
                        break
                left_index -= 1
        right_index = peak_index
        while right_index < len(abs_deviation ) - 1:
                if abs_deviation[right_index] < half_level:
                        break
                right_index += 1
        x_region = voltage[left_index:right_index + 1]
        y_region = np.abs(deviation[left_index:right_index + 1])

        if len(x_region) < 2:
                return 0.0
        area = np.trapezoid(y_region, x_region)
        return float(abs(area))

def calculate_peak_prominence(deviation, peak_index):
        #uoc luong peak prominece

        prominence = abs(float(deviation[peak_index]))
        return float(prominence)

def calculate_peak_symmetry(voltage, deviation, peak_index):
        #Uoc luoong do doi xung cua peak
        peak_abs = abs(deviation[peak_index])
        if peak_abs <= 0:
                return 0.0
        half_level = peak_abs * 0.5

        abs_deviation = np.abs(deviation)
        left_index = peak_index
        while left_index > 0:
                if abs_deviation[left_index] < half_level:
                        break
                left_index -= 1

        right_index = peak_index
        while right_index < len(abs_deviation) - 1:
                if abs_deviation[right_index] < half_level:
                        break
                right_index += 1

        left_width = abs(voltage[peak_index] - voltage[left_index])
        right_width = abs(voltage[right_index] - voltage[peak_index])
        if left_width <= 0 or right_width <= 0:
                return 0.0
        symmetry = min(left_width, right_width) / max(left_width, right_width)
        return float(symmetry)

def extract_feature(voltage, current):
        # Ham chinh

        voltage, current = validate_input (voltage, current)
        features = {}
        # 1 => 6 Basic statistical features
        basic = calculate_basic_features(voltage, current)
        features.update(basic)
        # 7 => 9
        # Gradient features

        gradient_features, gradient = calculate_gradient_features (voltage, current)

        features.update(gradient_features)
        # 10 => 15
        #Peak features
        (peak_index, peak_current,peak_potential, baseline, deviation,) = find_main_peak(voltage, current)
        features["peakCurrent"] = peak_current
        features["peakPotential"] = peak_potential

        features["peakWidth"] = calculate_peak_width(voltage, deviation, peak_index)
        features["peakArea"] = calculate_peak_area(voltage, deviation,peak_index)
        features["peakProminence"] = calculate_peak_prominence(deviation, peak_index)
        features["peakSymmetry"] = calculate_peak_symmetry(voltage, deviation, peak_index)
        return features

def features_to_array(features):
        # Chuyen dictionary features thanh numpy array theo dung thu tu

        return np.array([features[name] for name in FEATURE_NAME],
                        dtype = float
                        )

def print_features(features):
        # In 15 features ra terminal

        print("=" *70)
        print("EXTRACTED FEATURES")
        print("=" *70)

        for index, name in enumerate(FEATURE_NAME, start=1):
                print(f"{index:02d}."
                      f"{name:<20}:"
                      f"{features[name]:.8f}")

        print("=" *70)

# QUICK TEST
if __name__ == "__main__":
        import sys
        from pathlib import Path

        # Them project root vafo PYTHONPATH
        PROJECT_ROOT = Path(__file__).resolve().parents[2]

        if str(PROJECT_ROOT) not in sys.path:
                sys.path.insert(0, str(PROJECT_ROOT))

        from config.substances import SUBSTANCES
        from src.simulation.signal_models import(generate_cv, generate_dpv, generate_swv)
        substance_name = "dopamine"
        params = SUBSTANCES[substance_name]
        concentration = 0.5
        ph = 7.0
        print()
        print("=" *70)
        print("FEATURE EXTRACTION TEST")
        print("=" *70)

        #CV
        print("\n[CV]")
        voltage_cv, current_cv = generate_cv(params=params, concentration = concentration, ph=ph, seed=42,)
        features_cv = extract_feature(voltage_cv, current_cv,)
        print_features(features_cv)

        #DVP
        print("\n[DVP]")
        voltage_dvp, current_dvp = generate_dpv(params=params, concentration=concentration, ph=ph, seed=42,)
        features_dvp = extract_feature(voltage_dvp, current_dvp,)
        print_features(features_dvp)

        #SWV
        print("\n[SWV]")
        voltage_swv, current_swv = generate_swv(params=params, concentration=concentration, ph=ph, seed=42,)
        features_swv = extract_feature(voltage_swv, current_swv,)
        print_features(features_swv)

        #ARRAY TEST
        feature_array = features_to_array(features_cv)
        print("\nFeature array:")
        print(feature_array)
        print("\nNumber of features:", len(feature_array))
                
