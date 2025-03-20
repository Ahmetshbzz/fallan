import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    // Paylaşılan örnek
    static let shared = ThemeManager()
    
    // Tema renkleri için @Published özellikler
    @Published var primaryColor: Color = AppTheme.primary
    @Published var secondaryColor: Color = AppTheme.secondary
    @Published var accentColor: Color = AppTheme.accent
    @Published var selectedTheme: Int = 0
    
    // Hazır tema seçenekleri - ThemeSettingsView ile aynı tanımlar
    private let themes: [[Color]] = [
        // Mor Tema (Mevcut)
        [Color(red: 0.09, green: 0, blue: 0.3), Color(red: 0.36, green: 0, blue: 0.51), Color(red: 0.55, green: 0.35, blue: 0.96)],
        // Mavi Tema
        [Color(red: 0.0, green: 0.2, blue: 0.4), Color(red: 0.0, green: 0.4, blue: 0.8), Color(red: 0.2, green: 0.5, blue: 1.0)],
        // Yeşil Tema
        [Color(red: 0.0, green: 0.3, blue: 0.1), Color(red: 0.1, green: 0.5, blue: 0.2), Color(red: 0.3, green: 0.7, blue: 0.2)],
        // Turuncu Tema
        [Color(red: 0.4, green: 0.1, blue: 0.0), Color(red: 0.7, green: 0.2, blue: 0.0), Color(red: 1.0, green: 0.5, blue: 0.0)],
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedTheme()
        setupNotificationListener()
    }
    
    private func setupNotificationListener() {
        // Tema değişiklik bildirimlerini dinle
        NotificationCenter.default
            .publisher(for: NSNotification.Name("AppThemeChanged"))
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                if let userInfo = notification.userInfo,
                   let primary = userInfo["primary"] as? Color,
                   let secondary = userInfo["secondary"] as? Color,
                   let accent = userInfo["accent"] as? Color {
                    
                    self.primaryColor = primary
                    self.secondaryColor = secondary
                    self.accentColor = accent
                    
                    // Burada uygulamanın görsel temasını güncelliyoruz
                    self.updateAppTheme()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadSavedTheme() {
        // UserDefaults'dan kaydedilmiş renkleri yükle
        let decoder = JSONDecoder()
        
        // Tema indeksi varsa direkt tema uygula
        selectedTheme = UserDefaults.standard.integer(forKey: "app_selected_theme")
        if selectedTheme > 0 && selectedTheme < themes.count {
            // Hazır tema varsa onu uygula
            applyTheme(index: selectedTheme)
            return
        }
        
        // Yoksa özel renkleri yüklemeye çalış
        if let primaryData = UserDefaults.standard.data(forKey: "app_primary_color"),
           let components = try? decoder.decode([CGFloat].self, from: primaryData),
           components.count >= 4 {
            primaryColor = Color(.sRGB, red: components[0], green: components[1], blue: components[2], opacity: components[3])
        }
        
        if let secondaryData = UserDefaults.standard.data(forKey: "app_secondary_color"),
           let components = try? decoder.decode([CGFloat].self, from: secondaryData),
           components.count >= 4 {
            secondaryColor = Color(.sRGB, red: components[0], green: components[1], blue: components[2], opacity: components[3])
        }
        
        if let accentData = UserDefaults.standard.data(forKey: "app_accent_color"),
           let components = try? decoder.decode([CGFloat].self, from: accentData),
           components.count >= 4 {
            accentColor = Color(.sRGB, red: components[0], green: components[1], blue: components[2], opacity: components[3])
        }
        
        // Kayıtlı renkler varsa uygulamanın temasını güncelle
        if UserDefaults.standard.data(forKey: "app_primary_color") != nil {
            updateAppTheme()
        }
    }
    
    // Temayı indeks ile uygula
    func applyTheme(index: Int) {
        guard index >= 0 && index < themes.count else { return }
        
        let theme = themes[index]
        primaryColor = theme[0]
        secondaryColor = theme[1]
        accentColor = theme[2]
        selectedTheme = index
        
        // UserDefaults'a kaydet
        UserDefaults.standard.set(index, forKey: "app_selected_theme")
        saveColors()
        
        // UI'ı güncelle
        updateAppTheme()
    }
    
    // Özel renkleri uygula
    func applyCustomColors(primary: Color, secondary: Color, accent: Color) {
        primaryColor = primary
        secondaryColor = secondary
        accentColor = accent
        
        // UserDefaults'a kaydet
        saveColors()
        
        // UI'ı güncelle
        updateAppTheme()
    }
    
    // Renkleri UserDefaults'a kaydet
    private func saveColors() {
        let encoder = JSONEncoder()
        
        if let primaryData = try? encoder.encode(primaryColor.cgColor?.components),
           let secondaryData = try? encoder.encode(secondaryColor.cgColor?.components),
           let accentData = try? encoder.encode(accentColor.cgColor?.components) {
            
            UserDefaults.standard.set(primaryData, forKey: "app_primary_color")
            UserDefaults.standard.set(secondaryData, forKey: "app_secondary_color")
            UserDefaults.standard.set(accentData, forKey: "app_accent_color")
        }
    }
    
    private func updateAppTheme() {
        // SwiftUI'ın tüm görünümleri otomatik olarak güncellemesi için bildirim gönderiyoruz
        objectWillChange.send()
    }
}

// MARK: - Tema Renkleri Uzantıları
// Bu uzantıları ana tema sistemi aktif edildiğinde ekleyebilirsiniz

/* Örnek kullanım:

extension Color {
    static var dynamicPrimary: Color {
        return ThemeManager.shared.primaryColor
    }
    
    static var dynamicSecondary: Color {
        return ThemeManager.shared.secondaryColor
    }
    
    static var dynamicAccent: Color {
        return ThemeManager.shared.accentColor
    }
}

extension LinearGradient {
    static var dynamicPrimary: LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.shared.primaryColor,
                ThemeManager.shared.secondaryColor
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
*/ 