import SwiftUI

internal struct ClockView: View {
    @AppStorage("isDarkMode") internal var isDarkMode: Bool = true
    @Binding internal var countdownTime: TimeInterval?
    @State private var selectedTime: Date = Date()
    @State private var isCountdownStarted: Bool = false
    @State private var isShowingTimePicker: Bool = false
    @State private var timer: Timer? = nil

    // Constants
    private let fontSize: CGFloat = 80
    private let buttonSpacing: CGFloat = 20
    private let paddingValue: CGFloat = 10
    private let minScaleFactor: CGFloat = 0.5
    private let timerInterval: TimeInterval = 1.0
    private let secondsPerHour: Int = 3600
    private let secondsPerMinute: Int = 60
    
    internal var body: some View {
        VStack {
            if isCountdownStarted, let countdownTime = countdownTime {
                Text(timeString(from: countdownTime))
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .minimumScaleFactor(minScaleFactor)
                    .lineLimit(1)
                    .padding()

                HStack(spacing: buttonSpacing) {
                    Button(action: showTimePicker) {
                        Text("UPDATE")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(paddingValue)
                    }

                    Button(action: resetCountdown) {
                        Text("STOP")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(paddingValue)
                    }
                }
            } else {
                Text("HH:MM")
                    .font(.system(size: fontSize, weight: .bold))
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
                        .cornerRadius(paddingValue)
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
                            .cornerRadius(paddingValue)
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

    // Private utility methods
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / secondsPerHour
        let minutes = (Int(interval) % secondsPerHour) / secondsPerMinute
        let seconds = Int(interval) % secondsPerMinute
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
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
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

internal struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView(countdownTime: .constant(3600))
    }
}
