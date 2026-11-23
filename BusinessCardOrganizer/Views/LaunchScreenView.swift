import SwiftUI

// MARK: - LaunchScreenView
// Initial launch screen for Business Card Organizer
// - Portrait orientation only (configured in project settings)
// - Uses design tokens for consistency
// - Animated presentation

struct LaunchScreenView: View {
    // MARK: - Properties
    @State private var appear = false
    @State private var logoScale: CGFloat = 0.8
    @State var isActive = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl.value) {
            // Logo text
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md.value) {
                Image(systemName: "businesscard")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(DesignTokens.accentPrimary)

                Text("Business")
                    .font(DesignTokens.TextStyle.h1)
                    .foregroundColor(DesignTokens.labelPrimary)
            }

            // Subtitle
            Text("Organizer")
                .font(DesignTokens.TextStyle.body)
                .foregroundColor(DesignTokens.labelSecondary)
                .offset(y: appear ? 0 : DesignTokens.Spacing.xl.value)

            // Simple divider
            Rectangle()
                .frame(height: 1)
                .foregroundColor(DesignTokens.lowEmphasis)
                .opacity(appear ? 1 : 0)

            // Tagline
            Text("Save. Organize. Connect.")
                .font(DesignTokens.TextStyle.caption)
                .foregroundColor(DesignTokens.labelSecondary)
                .offset(y: appear ? 0 : DesignTokens.Spacing.xl.value)
        }
        .scaleEffect(logoScale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.canvas)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.5, damping: 0.6)) {
                logoScale = 1.0
                appear = true
            }

            // Trigger active state transition after animation delay
            Dispatcher.delay(1.5) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

// MARK: - Dispatcher helper for delayed execution
enum Dispatcher {
    @MainActor
    static func delay(_ seconds: Double, execution: @escaping @MainActor () -> Void) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            execution()
        }
    }
}

// MARK: - LaunchScreenView Preview
struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .preferredColorScheme(.light)
    }
}
