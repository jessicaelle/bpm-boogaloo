import SwiftUI

struct NumberPadView: View {
    @Binding var bpm: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var bpmInput: String = ""

    // Constants
    private let titleFontSize: CGFloat = 24
    private let largeTitleFontSize: CGFloat = 34
    private let paddingValue: CGFloat = 16
    private let spacingValue: CGFloat = 20
    private let cornerRadius: CGFloat = 10
    private let buttonFontSize: CGFloat = 22

    var body: some View {
        VStack(spacing: spacingValue) {
            // Title
            Text("Enter BPM")
                .font(.system(size: titleFontSize, weight: .bold))
                .padding(paddingValue)

            // TextField for BPM Input
            TextField("BPM", text: $bpmInput)
                .keyboardType(.numberPad)
                .font(.system(size: largeTitleFontSize, weight: .bold))
                .padding(paddingValue)
                .background(Color(.systemGray6))
                .cornerRadius(cornerRadius)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .onAppear {
                    bpmInput = String(bpm)
                }

            // Button to Set BPM
            Button(action: {
                if let bpmValue = Int(bpmInput) {
                    bpm = bpmValue
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Set BPM")
                    .font(.system(size: buttonFontSize, weight: .bold))
                    .padding(paddingValue)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(paddingValue)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct NumberPadView_Previews: PreviewProvider {
    @State static var bpm = 120

    static var previews: some View {
        NumberPadView(bpm: $bpm)
    }
}
