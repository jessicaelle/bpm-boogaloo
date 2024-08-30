import SwiftUI

internal struct BPMInputView: View {
    @Binding internal var bpmInput: String
    @Binding internal var bpmFontSize: CGFloat
    @Binding internal var bpmColor: Color
    internal var wholeNumberBPM: Bool
    internal var isDarkMode: Bool

    // Constants
    private let baseFontSize: CGFloat = 100
    private let paddingValue: CGFloat = 16
    private let sampleText: String = "999.99"
    private let minFontSize: CGFloat = 10

    internal var body: some View {
        ZStack(alignment: .center) {
            Text("BPM")
                .font(.system(size: baseFontSize, weight: .bold))
                .foregroundColor(bpmInput.isEmpty ? bpmColor : .clear)

            TextField("", text: $bpmInput)
                .keyboardType(wholeNumberBPM ? .numberPad : .decimalPad)
                .font(.system(size: bpmFontSize, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(bpmInput.isEmpty ? .clear : bpmColor)
                .lineLimit(1)
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        let availableWidth = geometry.size.width * 0.9
                        calculateFontSizeForBPM(availableWidth: availableWidth)
                    }
                })
        }
        .padding(paddingValue)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(paddingValue)
    }

    // Private utility method
    private func calculateFontSizeForBPM(availableWidth: CGFloat) {
        let font = UIFont.systemFont(ofSize: baseFontSize, weight: .bold)
        var fontSize = baseFontSize
        var sampleSize = (sampleText as NSString).size(withAttributes: [.font: font])

        while sampleSize.width > availableWidth && fontSize > minFontSize {
            fontSize -= 1
            let adjustedFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            sampleSize = (sampleText as NSString).size(withAttributes: [.font: adjustedFont])
        }

        bpmFontSize = fontSize
    }
}

internal struct BPMInputView_Previews: PreviewProvider {
    @State static var bpmInput = "120"
    @State static var bpmFontSize: CGFloat = 100
    @State static var bpmColor: Color = .gray

    static var previews: some View {
        BPMInputView(
            bpmInput: $bpmInput,
            bpmFontSize: $bpmFontSize,
            bpmColor: $bpmColor,
            wholeNumberBPM: true,
            isDarkMode: true
        )
    }
}
