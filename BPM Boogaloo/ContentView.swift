import SwiftUI

struct ContentView: View {
    @Binding var showSettings: Bool
    @Binding var countdownTime: TimeInterval? // Binding for the countdown time
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("sliderPosition") var sliderPosition: String = "Right"
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true // AppStorage for wholeNumberBPM setting
    @State private var bpmInput: String = ""
    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var lastTapTime: Date? = nil
    @State private var bpmLocked: Bool = false
    @State private var pitchShift: Double = 0 {
        didSet {
            updateBPMWithPitchShift()
        }
    }
    @State private var transitionTips: [TransitionTip] = [
        TransitionTip(title: "Halftime", multiplier: 0.5),
        TransitionTip(title: "Doubletime", multiplier: 2.0),
        TransitionTip(title: "Range", range: true),
        TransitionTip(title: "¾ Loop Up", multiplier: 4/3),
        TransitionTip(title: "¾ Loop Down", multiplier: 3/4)
    ]
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Add the CountdownBannerView, but only show it if the countdown time is set
            if countdownTime != nil {
                CountdownBannerView(countdownTime: $countdownTime)
            }

            ZStack(alignment: .center) {
                if bpmInput.isEmpty && !isTapping {
                    Text("BPM")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.gray)
                }

                TextField("", text: $bpmInput)
                    .keyboardType(wholeNumberBPM ? .numberPad : .decimalPad) // Allow decimals if wholeNumberBPM is false
                    .font(.system(size: 100, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.3)  // Added to resize the font automatically
                    .lineLimit(1)             // Ensure it stays on one line
                    .onChange(of: bpmInput) { oldValue, newValue in
                        if newValue.count > 5 {
                            bpmInput = String(newValue.prefix(5))
                        }
                        if !newValue.isEmpty {
                            isTapping = false
                            bpmLocked = false
                            tapTimes.removeAll()
                            print("BPM input manually set: \(newValue)")
                        }
                    }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            // Add the horizontal pitch fader below the BPM display
            PitchFader(pitchShift: $pitchShift)
            
            BPMTapperView(bpmInput: $bpmInput, bpmLocked: $bpmLocked)

            // Transition Tips Section
            TransitionTipsView(
                transitionTips: $transitionTips,
                bpmInput: $bpmInput,
                isEditing: $isEditing,
                wholeNumberBPM: wholeNumberBPM // Pass the actual Bool value, not a binding
            )

            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            setupTapDetection()
        }
    }

    private func flashBPMPlaceholder() {
        withAnimation(Animation.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
            bpmInput = "BPM"
        }
        bpmInput = ""
    }

    private func updateBPMWithPitchShift() {
        guard let originalBPM = Double(bpmInput) else { return }
        let newBPM = originalBPM * (1 + pitchShift / 100)
        bpmInput = formattedBPM(newBPM)
        print("BPM updated with pitch shift: \(bpmInput)")
    }

    private func calculatedBPM(multiplier: Double) -> String {
        if let bpm = Double(bpmInput), bpm > 0 {
            return formattedBPM(bpm * multiplier)
        }
        return "0"
    }

    private func rangeText() -> String {
        if let bpm = Double(bpmInput), bpm > 0 {
            let lower = bpm * 0.94
            let upper = bpm * 1.06

            if wholeNumberBPM {
                // Use tildes for approximate values when whole number BPMs are on
                return "~\(formattedBPM(lower)) to ~\(formattedBPM(upper)) BPM"
            } else {
                // Exact values without tildes when whole number BPMs are off
                return "\(formattedBPM(lower)) to \(formattedBPM(upper)) BPM"
            }
        }

        // Default case when there's no BPM established
        return "0 to 0 BPM"
    }

    private func formattedBPM(_ bpm: Double) -> String {
        return wholeNumberBPM ? String(Int(round(bpm))) : String(format: "%.1f", bpm)
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
        bpmLocked = false
        print("BPM calculated: \(bpmInput)")

        if tapTimes.count > 4 {
            tapTimes.removeFirst(tapTimes.count - 12)
        }
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

    private func moveTip(from source: IndexSet, to destination: Int) {
        transitionTips.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteTip(at offsets: IndexSet) {
        transitionTips.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
