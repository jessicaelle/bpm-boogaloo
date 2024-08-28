import SwiftUI

struct ContentView: View {
    @Binding var showSettings: Bool
    @Binding var countdownTime: TimeInterval?
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("sliderPosition") var sliderPosition: String = "Right"
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true

    @State private var bpmInput: String = ""
    @State private var originalBPM: Double = 0.0
    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var bpmLocked: Bool = false
    @State private var pitchShift: Double = 0.0

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
                    .keyboardType(wholeNumberBPM ? .numberPad : .decimalPad)
                    .font(.system(size: 100, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
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
                        Text("Pitch Shift:")
                        Spacer()
                        Text("\(pitchShift, specifier: "%.1f")%")
                    }
                    .font(.caption)
                    .padding(.horizontal)

                    Stepper(value: $pitchShift, in: -6...6, step: 0.1) {
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
    }

    private func registerTap() {
        let now = Date()
        tapTimes.append(now)
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
        print("BPM calculated: \(bpmInput)")
    }

    private func lockBPM() {
        guard let bpm = Double(bpmInput), bpm > 0 else { return }
        originalBPM = bpm
        bpmLocked = true
        updateDisplayedBPM()
        updateTransitionTipsBPM(with: originalBPM)
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
        return wholeNumberBPM ? String(Int(round(bpm))) : String(format: "%.1f", bpm)
    }

    private func resetBPM() {
        bpmInput = ""
        originalBPM = 0.0
        bpmLocked = false
        pitchShift = 0.0
        tapTimes.removeAll()
        isTapping = false
        print("BPM and Pitch Reset")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSettings: .constant(false), countdownTime: .constant(nil))
    }
}
