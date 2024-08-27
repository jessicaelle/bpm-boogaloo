import SwiftUI

struct AbstractShape: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Define the three points of the triangle
                path.move(to: CGPoint(x: width * 0.5, y: height * 0.1)) // Top vertex
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.9)) // Bottom-right vertex
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.9)) // Bottom-left vertex
                path.closeSubpath() // Close the triangle
            }
            .stroke(Color.primary, lineWidth: 6) // Draw the triangle with a bold line
        }
        .frame(width: 50, height: 50)
    }
}

struct AbstractShape_Previews: PreviewProvider {
    static var previews: some View {
        AbstractShape()
            .frame(width: 100, height: 100)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light) // Preview in light mode
    }
}
