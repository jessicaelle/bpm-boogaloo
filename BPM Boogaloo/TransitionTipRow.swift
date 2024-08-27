import SwiftUI

struct TransitionTipRow: View {
    let title: String
    let calculation: String
    let isEditing: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .padding(.vertical, 4)
                .padding(.horizontal)

            Spacer()

            if !isEditing {
                Text(calculation)
                    .font(.body)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
            }
        }
    }
}

struct TransitionTipRow_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTipRow(
            title: "Halftime",
            calculation: "60 BPM",
            isEditing: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
