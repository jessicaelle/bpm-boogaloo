import SwiftUI

struct CountdownBannerView: View {
    @Binding var countdownTime: TimeInterval?

    var body: some View {
        if let countdownTime = countdownTime, countdownTime > 0 {
            HStack {
                Text(timeString(from: countdownTime))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .background(colorForTimeRemaining(countdownTime)) // Background color based on time
                    .cornerRadius(8)

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func colorForTimeRemaining(_ timeRemaining: TimeInterval) -> Color {
        let minutesRemaining = timeRemaining / 60

        if minutesRemaining > 10 {
            return .green
        } else if minutesRemaining > 5 {
            return .orange // You can change this to .gold if you prefer
        } else {
            return .red
        }
    }
}

struct CountdownBannerView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownBannerView(countdownTime: .constant(3600))
    }
}
