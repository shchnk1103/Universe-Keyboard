#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import CryptoKit
import KeyboardCore
import UIKit

extension KeyboardViewController {
    @discardableResult
    func consumeFreshPreparedDevicePreflightRunIfAvailable() -> Bool {
        guard let consumption =
            T9DevicePreflightRun.consumeFreshPreparedEnvelope(
                serialized: sharedDefaults?.string(
                    forKey: T9DevicePreflightRun.envelopeKey
                ),
                currentToken: devicePreflightRunToken
            )
        else {
            return false
        }

        devicePreflightRunToken = consumption.token
        devicePreflightPreparedGeometryDigest = nil
        devicePreflightDidRecordExecutionGeometry = false
        sharedDefaults?.set(
            consumption.consumedEnvelope.serialized,
            forKey: T9DevicePreflightRun.envelopeKey
        )
        // This is a pre-arm visibility boundary, never a key-handling path.
        sharedDefaults?.synchronize()
        HotPathSegmentTiming.beginDevicePreflightRun(token: consumption.token)
        recordDevicePreflightMarker(runToken: consumption.token)
        return true
    }

    func recordDevicePreflightMarker(runToken: String) {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED
        Logger.shared.devicePreflightPerformance(
            "T9DEVICE schema=v1 marker=T9DEVICE_ENABLED run=\(runToken) gate=on measurement=on"
        )
        #else
        Logger.shared.devicePreflightPerformance(
            "T9DEVICE schema=v1 marker=T9DEVICE_DISABLED run=\(runToken) gate=off measurement=on"
        )
        #endif
        Logger.shared.requestFlush()
    }

    func recordDevicePreflightPreparedGeometryIfPossible() {
        guard devicePreflightPreparedGeometryDigest == nil,
              let geometry = makeDevicePreflightGeometry()
        else {
            return
        }
        devicePreflightPreparedGeometryDigest = geometry.digest
        Logger.shared.devicePreflightPerformance(
            geometry.record(phase: "prepared")
        )
        Logger.shared.requestFlush()
    }

    func recordDevicePreflightExecutionGeometryBeforeFirstT9Key() {
        guard !devicePreflightDidRecordExecutionGeometry else {
            return
        }
        guard let geometry = makeDevicePreflightGeometry() else {
            Logger.shared.devicePreflightPerformance(
                "T9GEOM schema=v1 phase=execution run=\(devicePreflightRunToken ?? "invalid") "
                    + "status=unavailable"
            )
            return
        }
        // Mark only after a complete geometry snapshot is available. A layout
        // pass can run before the T9 buttons/window are ready; leaving the flag
        // false lets the next lifecycle pass retry instead of freezing an
        // unavailable result for the entire arm.
        devicePreflightDidRecordExecutionGeometry = true
        Logger.shared.devicePreflightPerformance(
            geometry.record(phase: "execution")
        )
    }

    private func makeDevicePreflightGeometry() -> DevicePreflightGeometry? {
        guard let token = devicePreflightRunToken,
              T9DevicePreflightRun.isCanonicalToken(token),
              devicePreflightT9LetterGroupButtons.count == 8,
              let screen = view.window?.windowScene?.screen
        else {
            return nil
        }

        let coordinateSpace = screen.coordinateSpace
        let screenBounds = coordinateSpace.bounds
        guard screenBounds.height > screenBounds.width else {
            return nil
        }
        let slots = devicePreflightT9LetterGroupButtons.map {
            coordinateSpace.convert($0.bounds, from: $0)
        }
        guard let firstSlot = slots.first,
              slots.allSatisfy({ !$0.isEmpty })
        else {
            return nil
        }
        // UIInputViewController's root view can span the host screen on a
        // physical device. The actual tappable keyboard region is the envelope
        // of the measured T9 buttons, which are also the driver's only targets.
        let keyboardFrame = slots.dropFirst().reduce(firstSlot) {
            $0.union($1)
        }
        return DevicePreflightGeometry(
            token: token,
            screen: screenBounds,
            nativeScale: screen.nativeScale,
            keyboard: keyboardFrame,
            slots: slots
        )
    }
}

private struct DevicePreflightGeometry {
    let token: String
    let screen: CGRect
    let nativeScale: CGFloat
    let keyboard: CGRect
    let slots: [CGRect]

    var digest: String {
        SHA256.hash(data: Data(canonical.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    func record(phase: String) -> String {
        "T9GEOM schema=v1 phase=\(phase) run=\(token) digest=\(digest) "
            + "space=portrait-screen-points orientation=portrait "
            + "screen=\(Self.rect(screen)) scale=\(Self.number(nativeScale)) "
            + "keyboard=\(Self.rect(keyboard)) "
            + slots.enumerated()
                .map { "s\($0.offset)=\(Self.rect($0.element))" }
                .joined(separator: " ")
    }

    private var canonical: String {
        "v1|run=\(token)|space=portrait-screen-points|orientation=portrait"
            + "|screen=\(Self.rect(screen))|scale=\(Self.number(nativeScale))"
            + "|keyboard=\(Self.rect(keyboard))|"
            + slots.enumerated()
                .map { "s\($0.offset)=\(Self.rect($0.element))" }
                .joined(separator: "|")
    }

    private static func rect(_ rect: CGRect) -> String {
        [
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height,
        ].map(number).joined(separator: ",")
    }

    private static func number(_ value: CGFloat) -> String {
        String(
            format: "%.3f",
            locale: Locale(identifier: "en_US_POSIX"),
            Double(value)
        )
    }
}
#endif
