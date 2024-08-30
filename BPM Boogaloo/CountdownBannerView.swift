import SwiftUI

internal struct CountdownBannerView: View {
    @Binding internal var countdownTime: TimeInterval?

    // Constants
    private let fontSize: CGFloat = 20
    private let verticalPadding: CGFloat = 5
    private let horizontalPadding: CGFloat = 15
    private let cornerRadius: CGFloat = 8
    private let greenThreshold: TimeInterval = 600  // 10 minutes in seconds
    private let orangeThreshold: TimeInterval = 300  // 5 minutes in seconds

    internal var body: some View {
        if let countdownTime = countdownTime, countdownTime > 0 {
            HStack {
                Text(timeString(from: countdownTime))
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, verticalPadding)
                    .padding(.horizontal, horizontalPadding)
                    .background(colorForTimeRemaining(countdownTime))
                    .cornerRadius(cornerRadius)

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    // Private utility methods
    private func timeString(from interval: TimeInterval) -> String {
        let hours: Int = Int(interval) / 3600
        let minutes: Int = (Int(interval) % 3600) / 60
        let seconds: Int = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func colorForTimeRemaining(_ timeRemaining: TimeInterval) -> Color {
        let minutesRemaining: Double = timeRemaining / 60

        if minutesRemaining > greenThreshold / 60 {
            return .green
        } else if minutesRemaining > orangeThreshold / 60 {
            return .orange
        } else {
            return .red
        }
    }
}

internal struct CountdownBannerView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownBannerView(countdownTime: .constant(3600))
    }
}
