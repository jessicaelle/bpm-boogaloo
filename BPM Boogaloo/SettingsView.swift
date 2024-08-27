import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true
    @AppStorage("orangeAlertMinutes") var orangeAlertMinutes: Double = 10
    @AppStorage("redAlertMinutes") var redAlertMinutes: Double = 5

    var body: some View {
        NavigationView {  // Wrap the form in NavigationView for proper navigation title
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
            }
            .navigationTitle("Settings")  // Ensure navigation title is correctly set
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
