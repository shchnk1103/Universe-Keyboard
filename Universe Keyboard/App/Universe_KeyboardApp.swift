//
//  Universe_KeyboardApp.swift
//  Universe Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//

import SwiftUI

@main
struct Universe_KeyboardApp: App {
    init() {
        AppAppearance.migrateLegacyPreferenceIfNeeded()
        RimeSyncNotificationService.shared.configure()
        RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
