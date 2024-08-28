import SwiftUI

struct PitchFaderTestView: View {
    @State private var pitchShift: Double = 0.0

    var body: some View {
        PitchFader(pitchShift: $pitchShift)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
            .edgesIgnoringSafeArea(.all)
    }
}

struct PitchFaderTestView_Previews: PreviewProvider {
    static var previews: some View {
        PitchFaderTestView()
    }
}
