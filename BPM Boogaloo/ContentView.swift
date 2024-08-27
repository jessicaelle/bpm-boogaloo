import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true // Persistent storage for Dark Mode
    @State private var bpmInput: String = ""
    @State private var isTapping: Bool = false
    @State private var tapTimes: [Date] = []
    @State private var lastTapTime: Date? = nil
    @State private var bpmLocked: Bool = false
    @State private var showSettings = false
    @State private var transitionTips: [TransitionTip] = [
        TransitionTip(title: "Halftime", multiplier: 0.5),
        TransitionTip(title: "Doubletime", multiplier: 2.0),
        TransitionTip(title: "Range", range: true),
        TransitionTip(title: "¾ Loop Up", multiplier: 4/3),
        TransitionTip(title: "¾ Loop Down", multiplier: 3/4)
    ]
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                AbstractShape()
                    .onTapGesture {
                        showSettings.toggle()
                    }
                    .padding()

                Spacer()
            }

            // BPM Input Field with Custom Placeholder
            ZStack(alignment: .center) {
                if bpmInput.isEmpty && !isTapping {
                    Text("BPM")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.gray)
                }

                TextField("", text: $bpmInput)
                    .keyboardType(.numberPad)
                    .font(.system(size: 100, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .onChange(of: bpmInput) { oldValue, newValue in
                        if newValue.count > 3 {
                            bpmInput = String(newValue.prefix(3))
                        }
                        if !newValue.isEmpty {
                            isTapping = false
                            bpmLocked = false
                            tapTimes.removeAll()
                            print("BPM input manually set: \(newValue)")
                        }
                    }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            // TAP/RESET Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if bpmLocked {
                        resetBPM()
                    } else {
                        registerTap()
                    }
                }) {
                    Text(bpmLocked ? "RESET" : "TAP")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(bpmLocked ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            // Transition Tips Section
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
                                            transitionTips[index].hidden.toggle()
                                        }
                                    }) {
                                        Image(systemName: transitionTips[index].hidden ? "eye" : "eye.slash")
                                            .foregroundColor(transitionTips[index].hidden ? .green : .red)
                                    }
                                }

                                TransitionTipRow(
                                    title: transitionTips[index].title,
                                    calculation: transitionTips[index].range ? rangeText() : "\(calculatedBPM(multiplier: transitionTips[index].multiplier ?? 1.0)) BPM"
                                )
                            }
                        }
                    }
                    .onMove(perform: moveTip)
                }
                .listStyle(PlainListStyle())
                .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light) // Apply the color scheme based on user preference
        .onAppear {
            setupTapDetection()
        }
        // Present the SettingsView modally
        .sheet(isPresented: $showSettings) {
            SettingsView(showSettings: $showSettings)
        }
    }

    // Function to calculate BPM based on a multiplier
    private func calculatedBPM(multiplier: Double) -> Int {
        if let bpm = Int(bpmInput), bpm > 0 {
            return Int(Double(bpm) * multiplier)
        }
        return 0
    }

    // Function to generate range text
    private func rangeText() -> String {
        if let bpm = Int(bpmInput), bpm > 0 {
            let lower = Int(Double(bpm) * 0.94)
            let upper = Int(Double(bpm) * 1.06)
            return "~\(lower) to ~\(upper) BPM"
        }
        return "~0 to ~0 BPM"
    }

    private func registerTap() {
        guard !bpmLocked else {
            print("Tap ignored: BPM is locked.")
            return
        }

        let now = Date()
        tapTimes.append(now)
        lastTapTime = now
        print("Tap registered at \(now). Total taps: \(tapTimes.count)")

        if tapTimes.count >= 4 {
            calculateBPM()
        }

        isTapping = true
    }

    private func calculateBPM() {
        guard tapTimes.count >= 4 else {
            print("Not enough taps to calculate BPM")
            return
        }

        let intervals = zip(tapTimes.dropLast(), tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)

        let bpm = 60.0 / averageInterval
        bpmInput = "\(Int(round(bpm)))"
        bpmLocked = false // Keep the BPM unlocked to continue rolling average
        print("BPM calculated: \(bpmInput)")

        // Continue updating every 4 taps
        if tapTimes.count > 4 {
            tapTimes.removeFirst(tapTimes.count - 12) // Keep only the most recent 12 taps to maintain a rolling average
        }
    }

    private func resetBPM() {
        bpmInput = ""
        tapTimes.removeAll()
        isTapping = false
        bpmLocked = false
        lastTapTime = nil
        print("BPM reset. Tap state cleared.")
    }

    private func setupTapDetection() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let lastTapTime = lastTapTime else { return }
            if !bpmLocked && Date().timeIntervalSince(lastTapTime) > 2 {
                bpmLocked = true
                print("BPM locked due to inactivity.")
            }
        }
    }

    private func moveTip(from source: IndexSet, to destination: Int) {
        transitionTips.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteTip(at offsets: IndexSet) {
        transitionTips.remove(atOffsets: offsets)
    }
}

struct TransitionTip: Identifiable {
    let id = UUID()
    let title: String
    let multiplier: Double?
    let range: Bool
    var hidden: Bool = false // New property to track hidden state

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


struct TransitionTipRow: View {
    let title: String
    let calculation: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .padding()

            Spacer()

            Text(calculation)
                .font(.body)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
