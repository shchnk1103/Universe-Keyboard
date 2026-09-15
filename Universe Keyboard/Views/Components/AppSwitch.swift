//
//  AppSwitch.swift
//  Universe Keyboard
//
//  Shared main-App switch chrome. Hosts system UISwitch; does not draw a
//  custom track or thumb. Dark-on uses a black thumb so it stays visible on
//  the white on-track created by `.tint(.primary)`.
//

import SwiftUI
import UIKit

/// Contrast pair for every main-App switch (`PD-APP-SWITCH-CONTRAST-001`).
enum AppSwitchChrome: Sendable {
    /// On-track follows label: black in light, white in dark.
    nonisolated static func onTintColor() -> UIColor {
        .label
    }

    /// Thumb stays white except dark-on, where it is black against the white track.
    nonisolated static func thumbTintColor(isOn: Bool, isDark: Bool) -> UIColor {
        if isDark && isOn {
            return .black
        }
        return .white
    }
}

/// System `UISwitch` with the locked on-tint / thumb-tint pair.
struct AppSwitch: UIViewRepresentable {
    @Binding var isOn: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeCoordinator() -> Coordinator {
        Coordinator(isOn: $isOn)
    }

    func makeUIView(context: Context) -> UISwitch {
        let control = UISwitch()
        control.setContentHuggingPriority(.required, for: .horizontal)
        control.setContentCompressionResistancePriority(.required, for: .horizontal)
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return control
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        context.coordinator.isOn = $isOn
        if uiView.isOn != isOn {
            uiView.setOn(isOn, animated: false)
        }
        uiView.isEnabled = isEnabled
        applyChrome(uiView, isDark: context.environment.colorScheme == .dark)
    }

    private func applyChrome(_ uiView: UISwitch, isDark: Bool) {
        uiView.onTintColor = AppSwitchChrome.onTintColor()
        uiView.thumbTintColor = AppSwitchChrome.thumbTintColor(
            isOn: uiView.isOn,
            isDark: isDark
        )
    }

    final class Coordinator: NSObject {
        var isOn: Binding<Bool>

        init(isOn: Binding<Bool>) {
            self.isOn = isOn
        }

        @objc func valueChanged(_ sender: UISwitch) {
            isOn.wrappedValue = sender.isOn
            sender.onTintColor = AppSwitchChrome.onTintColor()
            sender.thumbTintColor = AppSwitchChrome.thumbTintColor(
                isOn: sender.isOn,
                isDark: sender.traitCollection.userInterfaceStyle == .dark
            )
        }
    }
}

/// Form-safe style: layout only. Chrome is `UISwitch`, not a drawn Capsule.
struct AppSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer(minLength: 8)
            AppSwitch(isOn: configuration.$isOn)
        }
    }
}

extension ToggleStyle where Self == AppSwitchToggleStyle {
    static var appSwitch: AppSwitchToggleStyle {
        AppSwitchToggleStyle()
    }
}
