import SwiftUI

// MARK: - LoadingView
// A reusable loading indicator with consistent styling
// Follows anti-ai-slop guidelines: subtle motion, no generic spinners

struct LoadingView: View {
    // MARK: - Properties
    let style: Style
    var progress: Double?

    // MARK: - Style Enum
    enum Style {
        case circular(progress: Double?)
        case bar(Double)
    }

    // MARK: - Body
    var body: some View {
        Group {
            switch style {
            case .circular(let progress):
                CircularLoadingView(progress: progress)
            case .bar(let progress):
                BarLoadingView(progress: progress)
            }
        }
    }
}

// MARK: - CircularLoadingView
struct CircularLoadingView: View {
    let progress: Double?

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.1)
                .foregroundColor(DesignTokens.accentPrimary)

            if let progress = progress {
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .foregroundColor(DesignTokens.accentPrimary)
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - BarLoadingView
struct BarLoadingView: View {
    let progress: Double?

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: 40, height: 8)
                .opacity(0.1)
                .foregroundColor(DesignTokens.separator)

            if let progress = progress {
                Rectangle()
                    .frame(width: 40 * CGFloat(progress), height: 8)
                    .foregroundColor(DesignTokens.accentPrimary)
            }
        }
        .frame(width: 40, height: 8)
    }
}

// MARK: - Preview Provider
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DesignTokens.Spacing.lg.value) {
            LoadingView(style: .circular(progress: 0.5))
            LoadingView(style: .bar(progress: 0.7))
        }
        .padding(DesignTokens.Spacing.xl.value)
        .background(DesignTokens.canvas)
    }
}