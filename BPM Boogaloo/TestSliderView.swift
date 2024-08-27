import SwiftUI

struct TestSliderView: View {
    @State private var sliderValue: Double = 0.0
    
    var body: some View {
        VStack {
            Text("Slider Value: \(sliderValue, specifier: "%.1f")")
                .padding()
            
            Slider(value: $sliderValue, in: -6...6, step: 0.1)
                .padding()
        }
    }
}

struct TestSliderView_Previews: PreviewProvider {
    static var previews: some View {
        TestSliderView()
    }
}
