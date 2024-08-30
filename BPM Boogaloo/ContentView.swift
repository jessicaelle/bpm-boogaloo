import SwiftUI

struct ContentView: View {
    @Binding var showSettings: Bool
    @Binding var countdownTime: TimeInterval?
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("sliderPosition") var sliderPosition: String = "Right"
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true
    @AppStorage("pitchRange") var pitchRange: String = "±6%"

    @State private var bpmInput: String = ""
    @State private var originalBPM: Double = 0.0
    @State private var bpmLocked: Bool = false
    @State private var pitchShift: Double = 0.0
    @State private var bpmColor: Color = .gray
    @State private var bpmFontSize: CGFloat = 100

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

            BPMInputView(
                bpmInput: $bpmInput,
                bpmFontSize: $bpmFontSize,
                bpmColor: $bpmColor,
                wholeNumberBPM: wholeNumberBPM,
                isDarkMode: isDarkMode
            )
            .onChange(of: bpmInput) { newValue in
                handleManualBPMInput(newValue)
            }

            BPMTapperView(
                bpmInput: $bpmInput,
                bpmLocked: $bpmLocked,
                bpmColor: $bpmColor,
                originalBPM: $originalBPM,
                isDarkMode: isDarkMode  // Pass isDarkMode to BPMTapperView
            )

            PitchAdjustmentView(
                pitchShift: $pitchShift,
                originalBPM: $originalBPM,
                bpmInput: $bpmInput,
                bpmLocked: bpmLocked,
                pitchRangeLimits: pitchRangeLimits(),
                onPitchChange: updateTransitionTipsBPM  // Update tips after pitch change
            )

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
            updateBPMColorAfterModeChange()
        }
    }

    private func pitchRangeLimits() -> ClosedRange<Double> {
        switch pitchRange {
        case "±10%":
            return -10...10
        case "±16%":
            return -16...16
        case "WIDE":
            return -100...100
        default:
            return -6...6
        }
    }

    private func updateTransitionTipsBPM() {
        let bpm = Double(bpmInput) ?? originalBPM
        for i in 0..<transitionTips.count {
            if let multiplier = transitionTips[i].multiplier {
                let calculatedBPM = formattedBPM(bpm * multiplier)
                transitionTips[i].calculatedBPM = calculatedBPM
            } else if transitionTips[i].range {
                transitionTips[i].calculatedBPM = rangeText(bpm: bpm)
            }
        }
    }

    private func rangeText(bpm: Double) -> String {
        let lower = bpm * 0.94
        let upper = bpm * 1.06
        return wholeNumberBPM ? "~\(formattedBPM(lower)) to ~\(formattedBPM(upper)) BPM" : "\(formattedBPM(lower)) to \(formattedBPM(upper)) BPM"
    }

    private func formattedBPM(_ bpm: Double) -> String {
        return String(format: "%.1f", bpm)
    }

    private func handleManualBPMInput(_ newValue: String) {
        guard let bpm = Double(newValue), bpm > 0 else { return }
        bpmInput = formattedBPM(bpm)
        originalBPM = bpm  // Update the original BPM as well
        updateTransitionTipsBPM()
    }

    private func updateBPMColorAfterModeChange() {
        if bpmLocked {
            bpmColor = isDarkMode ? .white : .black
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
