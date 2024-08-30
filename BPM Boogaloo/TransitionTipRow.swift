import SwiftUI

internal struct TransitionTipRow: View {
    internal let title: String
    internal let calculation: String
    internal let isEditing: Bool
    internal let bpmPlaceholderColor: Color // Color for the BPM label

    internal var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isEditing ? .primary : .gray)
            Spacer()
            Text(calculation.isEmpty ? "- BPM" : calculation) // Use a short hyphen here
                .foregroundColor(bpmPlaceholderColor)
        }
    }
}

internal struct TransitionTipRow_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTipRow(
            title: "Halftime",
            calculation: "",
            isEditing: false,
            bpmPlaceholderColor: .gray
        )
    }
}
