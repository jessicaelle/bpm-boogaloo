import SwiftUI

struct TransitionTip: Identifiable {
    let id = UUID()
    let title: String
    let multiplier: Double?
    let range: Bool
    var hidden: Bool = false
    var calculatedBPM: String = "- BPM"

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
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true

    // Constants
    private let listRowHeight: CGFloat = 44
    private let horizontalPadding: CGFloat = 16
    private let topPadding: CGFloat = 30
    private let verticalSpacing: CGFloat = 10
    private let bpmMultiplierLower: Double = 0.94
    private let bpmMultiplierUpper: Double = 1.06

    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            HStack {
                Text("BEAT GUIDE")
                    .font(.headline)
                    .padding(.top, topPadding)
                
                Spacer()
                
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
                .padding(.top, topPadding)
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
                                    Image(systemName: transitionTips[index].hidden ? "eye.slash" : "eye")
                                        .foregroundColor(transitionTips[index].hidden ? .red : .green)
                                }
                            }
                            
                            TransitionTipRow(
                                title: transitionTips[index].title,
                                calculation: transitionTips[index].calculatedBPM,
                                isEditing: isEditing,
                                bpmPlaceholderColor: bpmInput.isEmpty ? .gray : .primary
                            )
                        }
                    }
                }
                .onMove(perform: moveTip)
            }
            .listStyle(PlainListStyle())
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .frame(minHeight: CGFloat(transitionTips.count) * listRowHeight)
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, horizontalPadding)
        .onAppear {
            // Reorder tips with "Range" at the top
            transitionTips.sort { $0.title == "Range" || $1.title != "Range" }
        }
    }

    private func formattedBPM(multiplier: Double) -> String {
        guard let bpm = Double(bpmInput), bpm > 0 else { return "- BPM" }
        let calculatedBPM = bpm * multiplier
        return wholeNumberBPM ? String(Int(round(calculatedBPM))) : String(format: "%.2f", calculatedBPM)
    }
    
    private func rangeText() -> String {
        guard let bpm = Double(bpmInput), bpm > 0 else { return "- BPM" }
        let lower = bpm * bpmMultiplierLower
        let upper = bpm * bpmMultiplierUpper
        return wholeNumberBPM ? "~\(Int(round(lower))) to ~\(Int(round(upper))) BPM" : "\(String(format: "%.2f", lower)) to \(String(format: "%.2f", upper)) BPM"
    }
    
    private func moveTip(from source: IndexSet, to destination: Int) {
        transitionTips.move(fromOffsets: source, toOffset: destination)
    }

    func updateTransitionTipsBPM(_ newBPM: Double) {
        for i in 0..<transitionTips.count {
            if let multiplier = transitionTips[i].multiplier {
                transitionTips[i].calculatedBPM = formattedBPM(multiplier: multiplier)
            } else if transitionTips[i].range {
                transitionTips[i].calculatedBPM = rangeText()
            }
        }
    }
}

struct TransitionTipsView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTipsView(
            transitionTips: .constant([
                TransitionTip(title: "Range", range: true),
                TransitionTip(title: "Halftime", multiplier: 0.5),
                TransitionTip(title: "Doubletime", multiplier: 2.0)
            ]),
            bpmInput: .constant(""),
            isEditing: .constant(false)
        )
    }
}
