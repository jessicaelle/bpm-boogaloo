import SwiftUI

struct ClockView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @Binding var countdownTime: TimeInterval?
    @State private var selectedTime: Date = Date()  // Non-optional Date for time picker
    @State private var isCountdownStarted = false
    @State private var isShowingTimePicker = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            if isCountdownStarted, let countdownTime = countdownTime {
                Text(timeString(from: countdownTime))
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : .black)  // Adjust color based on mode
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding()

                HStack(spacing: 20) {
                    Button(action: showTimePicker) {
                        Text("UPDATE")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: resetCountdown) {
                        Text("STOP")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("HH:MM")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        showTimePicker()
                    }
                    .padding()

                Button(action: showTimePicker) {
                    Text("SET END TIME")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .sheet(isPresented: $isShowingTimePicker) {
            VStack {
                DatePicker(
                    "Select End Time",
                    selection: Binding(
                        get: { self.selectedTime },
                        set: { self.selectedTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())

                HStack {
                    Button(action: startCountdown) {
                        Text("START")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: dismissTimePicker) {
                        Image(systemName: "xmark.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Apply dark mode setting
    }

    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func showTimePicker() {
        isShowingTimePicker = true
    }

    private func dismissTimePicker() {
        isShowingTimePicker = false
    }

    private func startCountdown() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let targetTime = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)!
        countdownTime = targetTime.timeIntervalSince(now)
        isCountdownStarted = true
        isShowingTimePicker = false

        startTimer()
    }

    private func resetCountdown() {
        stopTimer()
        selectedTime = Date()
        countdownTime = nil
        isCountdownStarted = false
    }

    private func startTimer() {
        timer?.invalidate()  // Stop any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let countdownTime = countdownTime {
                if countdownTime > 0 {
                    self.countdownTime! -= 1
                } else {
                    self.resetCountdown()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView(countdownTime: .constant(3600))
    }
}
