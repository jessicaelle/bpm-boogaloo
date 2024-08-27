import SwiftUI

struct NumberPadView: View {
    @Binding var bpm: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var bpmInput: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Enter BPM")
                .font(.title)
                .padding()

            // TextField for BPM Input
            TextField("BPM", text: $bpmInput)
                .keyboardType(.numberPad)
                .font(.largeTitle)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
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
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct NumberPadView_Previews: PreviewProvider {
    @State static var bpm = 120

    static var previews: some View {
        NumberPadView(bpm: $bpm)
    }
}

