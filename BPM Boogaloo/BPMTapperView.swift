import SwiftUI

struct BPMTapperView: View {
    @Binding var bpmInput: String
    @Binding var bpmLocked: Bool
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true // AppStorage for wholeNumberBPM setting
    
    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var lastTapTime: Date? = nil
    
    var body: some View {
        HStack(spacing: 20) {
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
                    .cornerRadius(10)
            }
        }
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
        print("Tap registered at \(now). Total taps: \(tapTimes.count)")

        if tapTimes.count >= 4 {
            calculateBPM()
        }

        isTapping = true
    }

    private func calculateBPM() {
        guard tapTimes.count >= 4 else {
            print("Not enough taps to calculate BPM")
            return
        }

        let intervals = zip(tapTimes.dropLast(), tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)

        let bpm = 60.0 / averageInterval
        bpmInput = formattedBPM(bpm)
        bpmLocked = false // Keep the BPM unlocked to continue rolling average
        print("BPM calculated: \(bpmInput)")

        // Safely remove elements, keeping only the most recent 12 taps
        let maxTapsToKeep = 12
        if tapTimes.count > maxTapsToKeep {
            tapTimes.removeFirst(tapTimes.count - maxTapsToKeep)
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
        lastTapTime = nil
        print("BPM reset. Tap state cleared.")
    }

    private func setupTapDetection() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let lastTapTime = lastTapTime else { return }
            if !bpmLocked && Date().timeIntervalSince(lastTapTime) > 2 {
                bpmLocked = true
                print("BPM locked due to inactivity.")
            }
        }
    }
}

struct BPMTapperView_Previews: PreviewProvider {
    static var previews: some View {
        BPMTapperView(bpmInput: .constant("120"), bpmLocked: .constant(false))
    }
}
