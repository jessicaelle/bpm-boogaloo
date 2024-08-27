import SwiftUI

struct TransitionTip: Identifiable {
    let id = UUID()
    let title: String
    let multiplier: Double?
    let range: Bool
    var hidden: Bool = false

    init(title: String, multiplier: Double) {
        self.title = title
        self.multiplier = multiplier
        self.range = false
    }

    init(title: String, range: Bool) {
        self.title = title
        self.multiplier = nil
        self.range = range
    }
}

struct TransitionTipsView: View {
    @Binding var transitionTips: [TransitionTip]
    @Binding var bpmInput: String
    @Binding var isEditing: Bool
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true // AppStorage for wholeNumberBPM setting

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TRANSITION TIPS")
                    .font(.headline)
                    .padding(.top, 30)
                
                Spacer()
                
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
                .padding(.top, 30)
            }
            
            List {
                ForEach(transitionTips.indices, id: \.self) { index in
                    if !transitionTips[index].hidden || isEditing {
                        HStack {
                            if isEditing {
                                Button(action: {
                                    withAnimation {
                                        if index >= 0 && index < transitionTips.count {
                                            transitionTips[index].hidden.toggle()
                                        }
                                    }
                                }) {
                                    Image(systemName: transitionTips[index].hidden ? "eye" : "eye.slash")
                                        .foregroundColor(transitionTips[index].hidden ? .green : .red)
                                }
                            }
                            
                            TransitionTipRow(
                                title: transitionTips[index].title,
                                calculation: transitionTips[index].range ? rangeText() : "\(formattedBPM(multiplier: transitionTips[index].multiplier ?? 1.0)) BPM",
                                isEditing: isEditing
                            )
                        }
                    }
                }
                .onMove(perform: moveTip)
            }
            .listStyle(PlainListStyle())
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .frame(minHeight: CGFloat(transitionTips.count) * 44) // Assuming each row is approximately 44 points high
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal)
    }

    // Helper methods
    private func formattedBPM(multiplier: Double) -> String {
        guard let bpm = Double(bpmInput), bpm > 0 else { return "0" }
        let calculatedBPM = bpm * multiplier
        return wholeNumberBPM ? String(Int(round(calculatedBPM))) : String(format: "%.1f", calculatedBPM)
    }
    
    private func rangeText() -> String {
        guard let bpm = Double(bpmInput), bpm > 0 else { return "0 to 0 BPM" }
        let lower = bpm * 0.94
        let upper = bpm * 1.06
        return wholeNumberBPM ? "~\(Int(round(lower))) to ~\(Int(round(upper))) BPM" : "\(String(format: "%.1f", lower)) to \(String(format: "%.1f", upper)) BPM"
    }
    
    private func moveTip(from source: IndexSet, to destination: Int) {
        transitionTips.move(fromOffsets: source, toOffset: destination)
    }
}

struct TransitionTipsView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTipsView(
            transitionTips: .constant([
                TransitionTip(title: "Halftime", multiplier: 0.5),
                TransitionTip(title: "Doubletime", multiplier: 2.0)
            ]),
            bpmInput: .constant("120"),
            isEditing: .constant(false)
        )
    }
}
