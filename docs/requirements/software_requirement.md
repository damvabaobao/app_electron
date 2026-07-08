# ElectroChem AI
## 1. Giới thiệu
ElectrChem AI là hệ thống phân tích điện hóa thông minh sử dụng Raspberry Pi kết hợp mô hình AI nhằm nhận diện các chất hóa học và ước lượng lồng độ của chúng từ dữ liệu đo điện hóa
Hệ thống bao gồm:
-Raspberry Pi
-Mobile Application
-AI Model
-Database

## 2. Mục tiêu
-Thực hiện phép đo điện hóa
-Hiện thị đồ thị thời gian thực
-Phân tích dữ liệu bằng AI
-Dự đoán chất trong hỗn hợp
-Ước lượng nồng độ
-Lưu lịch sử đo

## 3. Phương pháp đo
Phiên bản đầu:
-Cyclic Voltammetry (CV)
-Diferential Pulse Voltammetry (DPV)
Các phiên bản sau:
-SWV
-EIS

## 4. Chức năng chính

### Dashboard

-Hiện thị trạng thái Raspberry Pi
-Hiện thị trạng thái kết nối
-Hiện thị phép đo gần nhất

### Measurement

-Chọn phương pháp đo
-Thiết lập thông số
-Start
-Stop

### Live Graph

-Hiện thị đồ thị theo thời gian thực

### AI Analysis

-Dự đoán chất
-Xác suất
-Nồng độ

### History

-Lưu lịch sử
-Xem lại đồ thị
-Xem lại kết quả AI

## 5. AI output

AI cần trả về:
-Danh sách chất
-Xác suất
-Nồng độ

Ví dụ:
Pb2+
Probability: 98%
Concentration: 2.3 ppm

## 6. Database

Lưu trên Raspberry PI
Bao gồm:
-Thời gian
-Phương pháp đo
-Dữ liệu CV/DVP
-Kết quả AI

## 7. Mobile App
Người dùng có thể:
-Kết nối Raspberry Pi
-Thực hiện phép đo
-Xem biểu đồ
-Xem kết quả
-Xem lịch sử