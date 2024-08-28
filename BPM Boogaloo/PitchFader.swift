import SwiftUI

struct PitchFader: View {
    @Binding var pitchShift: Double

    var body: some View {
        VStack {
            ZStack {
                // Background track with a dark gradient
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing  // Change direction for horizontal
                    ))
                    .frame(width: 300, height: 40) // Adjust dimensions for horizontal fader
                    .shadow(color: Color.black.opacity(0.8), radius: 10, x: 10, y: 5)
                
                // Slider overlay
                Slider(value: $pitchShift, in: -6...6, step: 0.1)
                    .frame(width: 300) // Adjust width for horizontal fader
                    .accentColor(Color.gray.opacity(0.5))  // Use a gray color to mimic the inactive state
                    .overlay(
                        GeometryReader { geometry in
                            // Calculate position of the floating label
                            let thumbPosition = CGFloat((pitchShift + 6) / 12) * geometry.size.width
                            
                            Text("\(pitchShift, specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .position(x: thumbPosition, y: -20)  // Position above the slider
                        }
                    )
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }
}

struct PitchFader_Previews: PreviewProvider {
    static var previews: some View {
        PitchFader(pitchShift: .constant(0))
    }
}
