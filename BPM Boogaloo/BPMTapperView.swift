import SwiftUI

struct BPMTapperView: View {
    @Binding var bpmInput: String
    @Binding var bpmLocked: Bool
    @Binding var bpmColor: Color
    @Binding var originalBPM: Double
    var isDarkMode: Bool
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true

    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var lastTapTime: Date? = nil

    // Constants
    private let minTapsForBPMCalculation = 4
    private let maxTapsToKeep = 12
    private let tapInactivityThreshold: TimeInterval = 2.0
    private let tapDetectionInterval: TimeInterval = 0.1
    private let buttonSpacing: CGFloat = 20
    private let buttonPadding: CGFloat = 10
    private let cornerRadius: CGFloat = 10
    private let flashAnimationDuration: TimeInterval = 0.02
    private let flashDelay: TimeInterval = 0.08

    var body: some View {
        HStack(spacing: buttonSpacing) {
            Button(action: {
                if bpmLocked {
                    resetBPM()
                } else {
                    registerTap()
                }
            }) {
                Text(bpmLocked ? "RESET" : "TAP")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(bpmLocked ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
            }

            if !bpmLocked {
                Button(action: {
                    lockBPM()
                }) {
                    Text("LOCK")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(cornerRadius)
                }
            }
        }
        .padding(buttonPadding)
        .onAppear {
            setupTapDetection()
        }
    }

    private func registerTap() {
        guard !bpmLocked else {
            print("Tap ignored: BPM is locked.")
            return
        }

        let now = Date()
        tapTimes.append(now)
        lastTapTime = now

        if tapTimes.count < minTapsForBPMCalculation {
            flashPlaceholder()
        } else {
            calculateBPM()
            updateBPMColor()  // Update BPM color based on the number of taps
        }

        isTapping = true
    }

    private func calculateBPM() {
        guard tapTimes.count >= minTapsForBPMCalculation else { return }

        let intervals = zip(tapTimes.dropLast(), tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        let bpm = 60.0 / averageInterval
        bpmInput = formattedBPM(bpm)
        originalBPM = bpm  // Store the original BPM for pitch adjustments

        if tapTimes.count > maxTapsToKeep {
            tapTimes.removeFirst(tapTimes.count - maxTapsToKeep)
        }
    }

    private func flashPlaceholder() {
        let baseColor = isDarkMode ? Color.white : Color.black
        let pulseColor = baseColor.opacity(0.4)

        withAnimation(.easeInOut(duration: flashAnimationDuration)) {
            bpmColor = pulseColor
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + flashDelay) {
            withAnimation(.easeInOut(duration: flashAnimationDuration)) {
                bpmColor = baseColor
            }
        }
    }

    private func updateBPMColor() {
        switch tapTimes.count {
        case 4...5:
            bpmColor = .red
        case 6...7:
            bpmColor = .orange
        case 8...:
            bpmColor = .green
        default:
            bpmColor = isDarkMode ? .white : .black
        }
    }

    private func formattedBPM(_ bpm: Double) -> String {
        return wholeNumberBPM ? String(Int(round(bpm))) : String(format: "%.1f", bpm)
    }

    private func resetBPM() {
        bpmInput = ""
        tapTimes.removeAll()
        isTapping = false
        bpmLocked = false
        bpmColor = .white
        lastTapTime = nil
        originalBPM = 0.0  // Ensure this resets when BPM is reset
    }

    private func lockBPM() {
        bpmLocked = true
    }

    private func setupTapDetection() {
        Timer.scheduledTimer(withTimeInterval: tapDetectionInterval, repeats: true) { _ in
            guard let lastTapTime = lastTapTime else { return }
            if !bpmLocked && Date().timeIntervalSince(lastTapTime) > tapInactivityThreshold {
                bpmLocked = true
                bpmColor = .white
            }
        }
    }
}

struct BPMTapperView_Previews: PreviewProvider {
    static var previews: some View {
        BPMTapperView(bpmInput: .constant("120"), bpmLocked: .constant(false), bpmColor: .constant(.gray), originalBPM: .constant(0), isDarkMode: true)
    }
}
