import SwiftUI

enum AppTheme {
    // Asset kataloğundan renkler
    static let primaryAsset = Color("Primary")
    static let secondaryAsset = Color("Secondary")
    static let accentAsset = Color("Accent")
    
    // Sabit tanımlı renkler (asset kataloğu bulunamadığında kullanılacak)
    static let primary = Color(red: 0.09, green: 0, blue: 0.3)
    static let secondary = Color(red: 0.36, green: 0, blue: 0.51)
    static let accent = Color(red: 0.55, green: 0.35, blue: 0.96)
    static let accentSecondary = Color(red: 0.22, green: 0.01, blue: 0.85)
    static let background = Color.black.opacity(0.9)
    static let card = Color.white.opacity(0.1)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let gold = Color(red: 0.97, green: 0.85, blue: 0.55)
    static let orange = Color(red: 0.95, green: 0.68, blue: 0.13)
    static let green = Color(red: 0.46, green: 0.76, blue: 0.26)
    
    // Gradientler
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [ThemeManager.shared.primaryColor, ThemeManager.shared.secondaryColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [ThemeManager.shared.accentColor, ThemeManager.shared.accentColor.opacity(0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.05, blue: 0.3, opacity: 0.7),
            Color(red: 0.2, green: 0.1, blue: 0.4, opacity: 0.7)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glowGradient = LinearGradient(
        gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Helper - Asset kataloğundan renk yükleme (fallback ile)
    static var primaryFromAsset: Color {
        do {
            return primaryAsset
        } catch {
            return primary // Hata durumunda sabit rengi kullan
        }
    }
    
    static var secondaryFromAsset: Color {
        do {
            return secondaryAsset
        } catch {
            return secondary // Hata durumunda sabit rengi kullan
        }
    }
    
    static var accentFromAsset: Color {
        do {
            return accentAsset
        } catch {
            return accent // Hata durumunda sabit rengi kullan
        }
    }
    
    // Tema renklerini değiştirme fonksiyonu
    static func updateThemeColors(
        primary: Color? = nil,
        secondary: Color? = nil,
        accent: Color? = nil,
        accentSecondary: Color? = nil,
        background: Color? = nil,
        text: Color? = nil
    ) {
        // Bu fonksiyon kullanıcı arayüzü üzerinden tema renklerini değiştirmek istediğimizde
        // gelecekte kullanılabilir. Şu an manuel değişiklikler için placeholder olarak duruyor.
    }
}

// Renk uzantıları
extension Color {
    // Dinamik renkler - ThemeManager'dan gelen değerleri kullan
    static var appPrimary: Color {
        ThemeManager.shared.primaryColor
    }
    
    static var appSecondary: Color {
        ThemeManager.shared.secondaryColor
    }
    
    static var appAccent: Color {
        ThemeManager.shared.accentColor
    }
    
    // Diğer renkler şimdilik sabit kalabilir
    static let appBackground = AppTheme.background
    static let appText = AppTheme.text
    static let appTextSecondary = AppTheme.textSecondary
    static let appCard = AppTheme.card
    static let appGold = AppTheme.gold
    static let appOrange = AppTheme.orange
    static let appGreen = AppTheme.green
    
    // Asset kataloğundan renk çağırma
    static func fromAsset(_ name: String) -> Color {
        return Color(name)
    }
}

// Gradient uzantıları
extension LinearGradient {
    // Dinamik gradient
    static var appPrimary: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var appAccent: LinearGradient {
        AppTheme.accentGradient
    }
    
    static let appCard = AppTheme.cardGradient
    static let appGlow = AppTheme.glowGradient
} 