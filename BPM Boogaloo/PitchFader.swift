import SwiftUI

struct PitchStepper: View {
    @Binding var pitchShift: Double

    var body: some View {
        VStack {
            Stepper(value: $pitchShift, in: -6...6, step: 0.1) {
                Text("Pitch Shift: \(pitchShift, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 40)

        }
        .padding()
    }
}

struct PitchStepper_Previews: PreviewProvider {
    static var previews: some View {
        PitchStepper(pitchShift: .constant(0))
    }
}
