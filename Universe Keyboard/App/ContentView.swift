//
//  ContentView.swift
//  Universe Keyboard
//
//  主页面：Tab 分为「引导」和「设置」。
//

import SwiftUI

let universeAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

struct ContentView: View {
    var body: some View {
        TabView {
            GuideTab()
                .tabItem {
                    Label("引导", systemImage: "book.pages")
                }
            SettingsTab()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
}
