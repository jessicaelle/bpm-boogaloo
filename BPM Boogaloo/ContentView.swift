import SwiftUI

struct ContentView: View {
    @Binding var showSettings: Bool
    @Binding var countdownTime: TimeInterval?
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("sliderPosition") var sliderPosition: String = "Right"
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true
    @AppStorage("pitchRange") var pitchRange: String = "±6%"  // Pulling the selected pitch range from settings

    @State private var bpmInput: String = ""
    @State private var originalBPM: Double = 0.0
    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var bpmLocked: Bool = false
    @State private var pitchShift: Double = 0.0
    @State private var bpmColor: Color = .gray
    @State private var bpmFontSize: CGFloat = 100  // Initialize with a base font size

    @State private var transitionTips: [TransitionTip] = [
        TransitionTip(title: "Range", range: true),
        TransitionTip(title: "Halftime", multiplier: 0.5),
        TransitionTip(title: "Doubletime", multiplier: 2.0),
        TransitionTip(title: "¾ Loop Up", multiplier: 4/3),
        TransitionTip(title: "¾ Loop Down", multiplier: 3/4)
    ]
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if countdownTime != nil {
                CountdownBannerView(countdownTime: $countdownTime)
            }

            ZStack(alignment: .center) {
                Text("BPM")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(bpmInput.isEmpty ? bpmColor : .clear)  // Ensure pulsing shows even when tapping

                TextField("", text: $bpmInput)
                    .keyboardType(wholeNumberBPM ? .numberPad : .decimalPad)
                    .font(.system(size: bpmFontSize, weight: .bold)) // Fixed font size based on `999.99`
                    .multilineTextAlignment(.center)
                    .foregroundColor(bpmInput.isEmpty ? .clear : bpmColor)  // Use bpmColor for pulsing and display
                    .lineLimit(1)
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            let availableWidth = geometry.size.width * 0.9  // Adjust according to your layout
                            calculateFontSizeForBPM(availableWidth: availableWidth)
                        }
                    })
                    .onChange(of: bpmInput) { newValue in
                        handleManualBPMInput(newValue)
                    }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            HStack {
                if !bpmLocked {
                    Button(action: {
                        registerTap()
                    }) {
                        Text("TAP")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if !bpmLocked {
                    Button(action: {
                        lockBPM()
                    }) {
                        Text("LOCK")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if bpmLocked {
                    Button(action: {
                        resetBPM()
                    }) {
                        Text("RESET")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)

            if bpmLocked {
                VStack {
                    HStack {
                        Spacer()
                        Text("\(pitchShift, specifier: "%.1f")%")
                    }
                    .font(.caption)
                    .padding(.horizontal)

                    Stepper(value: $pitchShift, in: pitchRangeLimits(), step: 0.1) {
                        Text("Adjust Pitch")
                    }
                    .onChange(of: pitchShift) { _ in
                        updateDisplayedBPM()
                    }
                }
            }

            TransitionTipsView(
                transitionTips: $transitionTips,
                bpmInput: $bpmInput,
                isEditing: $isEditing,
                wholeNumberBPM: wholeNumberBPM
            )

            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            updateBPMColorAfterModeChange()  // Ensure BPM color updates after mode change
        }
    }

    private func calculateFontSizeForBPM(availableWidth: CGFloat) {
        let sampleText = "999.99"
        let maxFontSize: CGFloat = 100  // The maximum font size
        let font = UIFont.systemFont(ofSize: maxFontSize, weight: .bold)

        var fontSize = maxFontSize
        var sampleSize = (sampleText as NSString).size(withAttributes: [.font: font])
        
        // Adjust the font size down until the text fits within the available width
        while sampleSize.width > availableWidth && fontSize > 10 { // 10 is a safe minimum size
            fontSize -= 1
            let adjustedFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            sampleSize = (sampleText as NSString).size(withAttributes: [.font: adjustedFont])
        }
        
        bpmFontSize = fontSize
    }

    private func pitchRangeLimits() -> ClosedRange<Double> {
        switch pitchRange {
        case "±10%":
            return -10...10
        case "±16%":
            return -16...16
        case "WIDE":
            return -100...100
        default:  // "±6%" or any undefined case
            return -6...6
        }
    }

    private func registerTap() {
        let now = Date()
        tapTimes.append(now)
        print("Tap registered at \(now). Total taps: \(tapTimes.count)")

        if tapTimes.count <= 3 {
            animateBPMColor()  // Pulse the color for the first 3 taps
        } else {
            updateBPMColor()  // Change color based on tap count (red/orange/green)
        }

        if tapTimes.count >= 4 {
            calculateBPM()
        }

        isTapping = true
    }

    private func animateBPMColor() {
        let baseColor = isDarkMode ? Color.white : Color.black
        let pulseColor = baseColor.opacity(0.4)

        withAnimation(.easeInOut(duration: 0.2)) {
            bpmColor = pulseColor
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {  // Slightly extend the timing for a smoother pulse
            withAnimation(.easeInOut(duration: 0.2)) {
                bpmColor = baseColor
            }
        }
    }
    
    private func updateBPMColorAfterModeChange() {
        if bpmLocked {
            bpmColor = isDarkMode ? .white : .black
        }
    }

    private func updateBPMColor() {
        let colorScheme = isDarkMode ? ColorScheme.dark : ColorScheme.light

        switch tapTimes.count {
        case 4...5:
            bpmColor = colorScheme == .dark ? .red : .red.opacity(0.8)
        case 6...7:
            bpmColor = colorScheme == .dark ? .orange : .orange.opacity(0.8)
        case 8...:
            bpmColor = colorScheme == .dark ? .green : .green.opacity(0.8)
        default:
            bpmColor = colorScheme == .dark ? .white : .black
        }
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
        print("BPM calculated: \(bpmInput)")
        updateTransitionTipsBPM(with: bpm)  // Update Transition Tips regardless of locking
    }

    private func lockBPM() {
        guard let bpm = Double(bpmInput), bpm > 0 else { return }
        originalBPM = bpm
        bpmLocked = true

        bpmColor = isDarkMode ? .white : .black

        updateDisplayedBPM()
        print("BPM locked at: \(originalBPM)")
    }


    private func updateDisplayedBPM() {
        guard bpmLocked else { return }

        let newBPM = originalBPM * (1 + (pitchShift / 100))
        print("Pitch Shift: \(pitchShift), Display BPM: \(newBPM)")
        bpmInput = formattedBPM(newBPM)
        updateTransitionTipsBPM(with: newBPM)
    }

   


    private func updateTransitionTipsBPM(with bpm: Double) {
        for i in 0..<transitionTips.count {
            if let multiplier = transitionTips[i].multiplier {
                let calculatedBPM = formattedBPM(bpm * multiplier)
                print("Updating \(transitionTips[i].title) to \(calculatedBPM)")
                transitionTips[i].calculatedBPM = calculatedBPM
            } else if transitionTips[i].range {
                let rangeTextValue = rangeText(bpm: bpm)
                print("Updating \(transitionTips[i].title) to range \(rangeTextValue)")
                transitionTips[i].calculatedBPM = rangeTextValue
            }
        }
    }

    private func rangeText(bpm: Double) -> String {
        let lower = bpm * 0.94
        let upper = bpm * 1.06

        if wholeNumberBPM {
            return "~\(formattedBPM(lower)) to ~\(formattedBPM(upper)) BPM"
        } else {
            return "\(formattedBPM(lower)) to \(formattedBPM(upper)) BPM"
        }
    }

    private func formattedBPM(_ bpm: Double) -> String {
        return wholeNumberBPM ? String(Int(round(bpm))) : String(format: "%.2f", bpm)
    }

    private func resetBPM() {
        bpmInput = ""
        originalBPM = 0.0
        bpmLocked = false
        pitchShift = 0.0
        tapTimes.removeAll()
        isTapping = false
        bpmColor = .gray
        print("BPM and Pitch Reset")
    }

    private func handleManualBPMInput(_ newValue: String) {
        guard let bpm = Double(newValue), bpm > 0 else { return }
        bpmInput = formattedBPM(bpm)
        updateTransitionTipsBPM(with: bpm)  // Update Transition Tips with manually entered BPM
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
