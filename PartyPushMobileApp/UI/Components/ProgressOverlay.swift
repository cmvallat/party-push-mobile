import SwiftUI

struct ProgressOverlay: View {
    var message: String = "Loading..."
    @State private var isSpinning = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 24) {
                Text(message)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Palette.deepTextColor,Palette.deepTextColor],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .padding(.top, 5)
                ZStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .clear))
                        .scaleEffect(1.2)
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isSpinning)
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(
                            LinearGradient(
                                colors: Palette.gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60 * 1.2, height: 60 * 1.2)
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isSpinning)
                        .opacity(0.9)
                }
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.27), radius: 30, x: 0, y: 20)
            )
        }
        .onAppear { isSpinning = true }
    }
}

#Preview {
    ProgressOverlay(message: "Joining the party...")
        .preferredColorScheme(.dark)
}
