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
    
    // ThemeManager'ı uygulamanın başlangıcında başlatıyoruz
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            // Tema yöneticisini tüm uygulama için erişilebilir yapıyoruz
            .environmentObject(themeManager)
        }
    }
}
