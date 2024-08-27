import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("wholeNumberBPM") var wholeNumberBPM: Bool = true
    @AppStorage("greenLimit") var greenLimit: Double = 10.0
    @AppStorage("orangeLimit") var orangeLimit: Double = 5.0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }

                Section(header: Text("Countdown")) {
                    VStack(alignment: .leading) {
                        Text("Set Time Limits")
                            .font(.headline)
                        Text("Green: More than")
                        HStack {
                            Slider(value: $greenLimit, in: 5...30, step: 1)
                            Text("\(Int(greenLimit)) minutes")
                        }
                        Text("Orange: Between")
                        HStack {
                            Slider(value: $orangeLimit, in: 1...greenLimit - 1, step: 1)
                            Text("\(Int(orangeLimit)) minutes")
                        }
                        Text("Red: Less than \(Int(orangeLimit)) minutes")
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 5)
                }

                Section(header: Text("BPM Settings")) {
                    Toggle(isOn: $wholeNumberBPM) {
                        Text("Whole Number BPMs")
                    }
                    .onChange(of: wholeNumberBPM) { _ in
                        NotificationCenter.default.post(name: .bpmSettingChanged, object: nil)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showSettings = false
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let bpmSettingChanged = Notification.Name("bpmSettingChanged")
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSettings: .constant(true))
    }
}
