# 📋Features  
  
### 🧠 Age-Based Heart Rate Thresholding  
Calculates optimal heart rate bounds using:  
Max_Heart_Rate = 220  
min_heart_threshold = (220 - age) / 2  
max_heart_threshold = ((220 - age) * 85) / 100  

### ⚙️ Finite State Machine (FSM)
Three well-defined states:  
Idle: Waiting for the system to start  
Measuring: Collecting heart beat samples  
Display: Showing diagnosis and BPM stats

### 📉 Heart Rate Diagnosis  
🚨 Overshoot: BPM > Max Threshold → Red LED & Buzzer 1  
🧊 Undershoot: BPM < Min Threshold → Blue LED & Buzzer 2  
✅ Optimal: BPM within range → Green LED

### 📊 Real-Time Data Display
15 Seven-Segment Displays used in groups of 3 (5 groups total):  
Total Beats Count  
Overshoot Count  
Undershoot Count  
Optimal Coun  
Average Heart Rate

### 🔁 Configurable Parameters  
Number of samples for averaging  
Duration of display stage
