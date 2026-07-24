import SwiftUI

// MARK: - Press feedback

/// Light scale-on-press for main-app cards and settings rows.
/// Skips scale when the user enables Reduce Motion.
struct AppPressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.98

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? pressedScale : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(
                reduceMotion
                    ? nil
                    : .easeOut(duration: 0.16),
                value: configuration.isPressed
            )
    }
}

// MARK: - Card entrance

/// Opacity + short rise for home (and similar) cards.
struct AppCardEntrance: ViewModifier {
    let isVisible: Bool
    var reduceMotion: Bool
    var offsetY: CGFloat = AppSpacing.entranceRise

    func body(content: Content) -> some View {
        content
            .opacity(isVisible || reduceMotion ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : offsetY)
    }
}

extension View {
    /// Soft card entrance. When `reduceMotion` is true, content is always fully shown.
    func appCardEntrance(isVisible: Bool, reduceMotion: Bool) -> some View {
        modifier(AppCardEntrance(isVisible: isVisible, reduceMotion: reduceMotion))
    }
}

enum AppMotion {
    /// Home card rise duration.
    static let entranceDuration: TimeInterval = 0.32
    /// Delay between staggered home cards.
    static let entranceStagger: TimeInterval = 0.055
    /// Status text / number transitions.
    static let statusCrossfade: TimeInterval = 0.2

    static var entranceAnimation: Animation {
        .easeOut(duration: entranceDuration)
    }

    static var statusAnimation: Animation {
        .easeInOut(duration: statusCrossfade)
    }
}
