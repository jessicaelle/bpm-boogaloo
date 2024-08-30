import SwiftUI

internal struct SettingsView: View {
    @AppStorage("isDarkMode") internal var isDarkMode: Bool = true
    @AppStorage("wholeNumberBPM") internal var wholeNumberBPM: Bool = true
    @AppStorage("orangeAlertMinutes") internal var orangeAlertMinutes: Double = 10
    @AppStorage("redAlertMinutes") internal var redAlertMinutes: Double = 5
    @AppStorage("pitchRange") internal var pitchRange: String = "±6%"  // Default pitch range

    // Internal array of pitch ranges
    private let pitchRanges = ["±6%", "±10%", "±16%", "WIDE"]

    internal var body: some View {
        NavigationView {
            Form {
                // Display Section
                Section(header: Text("Display")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    Toggle("Whole Number BPMs", isOn: $wholeNumberBPM)
                }

                // Clock Section
                Section(header: Text("Clock")) {
                    HStack {
                        Text("Orange Alert")
                        Spacer()
                        TextField("", value: $orangeAlertMinutes, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                        Text("Minutes")
                    }

                    HStack {
                        Text("Red Alert")
                        Spacer()
                        TextField("", value: $redAlertMinutes, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                        Text("Minutes")
                    }
                }

                // Pitch Fader Range Section
                Section(header: Text("Pitch Fader Range")) {
                    Picker("Select Pitch Range", selection: $pitchRange) {
                        ForEach(pitchRanges, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Settings")
        }
    }
}

internal struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
