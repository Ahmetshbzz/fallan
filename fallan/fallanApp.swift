//
//  fallanApp.swift
//  fallan
//
//  Created by Ahmet on 19.03.2025.
//

import SwiftUI

@main
struct fallanApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}
