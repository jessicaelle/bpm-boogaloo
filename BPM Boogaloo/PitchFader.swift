import SwiftUI

internal struct PitchAdjustmentView: View {
    @Binding internal var pitchShift: Double
    @Binding internal var originalBPM: Double
    @Binding internal var bpmInput: String
    internal var bpmLocked: Bool
    internal var pitchRangeLimits: ClosedRange<Double>
    internal var onPitchChange: () -> Void

    // Constants
    private let captionFontSize: CGFloat = 12
    private let horizontalPadding: CGFloat = 40
    private let generalPadding: CGFloat = 16
    private let captionColor: Color = .orange
    private let stepValue: Double = 0.1

    internal var body: some View {
        if bpmLocked {
            VStack {
                HStack {
                    Spacer()
                    Text("Pitch Shift: \(pitchShift, specifier: "%.1f")%")
                        .font(.system(size: captionFontSize))
                        .foregroundColor(captionColor)
                }
                .padding(.horizontal)

                Stepper(value: $pitchShift, in: pitchRangeLimits, step: stepValue) {
                    Text("Adjust Pitch")
                }
                .padding(.horizontal, horizontalPadding)
                .onChange(of: pitchShift) { _ in
                    updateDisplayedBPM()
                    onPitchChange()
                }
            }
            .padding(generalPadding)
        }
    }

    // Methods used internally within this view
    private func updateDisplayedBPM() {
        guard bpmLocked else { return }

        let adjustedBPM: Double = originalBPM * (1 + (pitchShift / 100))
        bpmInput = formattedBPM(adjustedBPM)
    }

    private func formattedBPM(_ bpm: Double) -> String {
        return String(format: "%.1f", bpm)
    }
}

internal struct PitchAdjustmentView_Previews: PreviewProvider {
    @State static var pitchShift: Double = 0
    @State static var originalBPM: Double = 120
    @State static var bpmInput: String = "120"

    static var previews: some View {
        PitchAdjustmentView(
            pitchShift: $pitchShift,
            originalBPM: $originalBPM,
            bpmInput: $bpmInput,
            bpmLocked: true,
            pitchRangeLimits: -6...6,
            onPitchChange: {}
        )
    }
}
