import SwiftUI

struct TransitionTipRow: View {
    let title: String
    let calculation: String
    let isEditing: Bool
    let bpmPlaceholderColor: Color // Color for the BPM label

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isEditing ? .primary : .gray)
            Spacer()
            Text(calculation.isEmpty ? "- BPM" : calculation) // Use a short hyphen here
                .foregroundColor(bpmPlaceholderColor)
        }
    }
}

struct TransitionTipRow_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTipRow(
            title: "Halftime",
            calculation: "",
            isEditing: false,
            bpmPlaceholderColor: .gray
        )
    }
}
