import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var primaryColor = AppTheme.primary
    @State private var secondaryColor = AppTheme.secondary
    @State private var accentColor = AppTheme.accent
    @State private var isDarkMode = true
    @State private var selectedTheme = 0
    
    // Hazır tema seçenekleri
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
    
    private let themeNames = ["Mor", "Mavi", "Yeşil", "Turuncu"]
    
    var body: some View {
        ZStack {
            LinearGradient.appPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Başlık bölümü
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.appText.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Tema Ayarları")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    // Sağ tarafta bir görünmez öğe ekleyerek ortalamanın doğru çalışmasını sağlayalım
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Hazır temalar
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hazır Temalar")
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<themes.count, id: \.self) { index in
                                themeButton(index: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Renk önizleme
                colorPreview()
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Özel Renk Seçimleri
                VStack(alignment: .leading, spacing: 12) {
                    Text("Özel Renkler")
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    ColorPicker("Ana Renk", selection: $primaryColor)
                        .foregroundColor(.appText)
                    
                    ColorPicker("İkincil Renk", selection: $secondaryColor)
                        .foregroundColor(.appText)
                    
                    ColorPicker("Vurgu Rengi", selection: $accentColor)
                        .foregroundColor(.appText)
                }
                .padding(.horizontal)
                
                // Uygula butonu
                Button(action: applyCustomTheme) {
                    Text("Temayı Uygula")
                }
                .appPrimaryButton()
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 30)
        }
        .onAppear {
            // Başlangıçta mevcut renkleri yükle
            primaryColor = themeManager.primaryColor
            secondaryColor = themeManager.secondaryColor
            accentColor = themeManager.accentColor
            selectedTheme = themeManager.selectedTheme
        }
    }
    
    private func themeButton(index: Int) -> some View {
        let theme = themes[index]
        
        return Button(action: {
            selectedTheme = index
            applyTheme(index: index)
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [theme[0], theme[1]]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .fill(theme[2])
                        .frame(width: 20, height: 20)
                }
                
                Text(themeNames[index])
                    .font(.caption)
                    .foregroundColor(.appText)
            }
        }
        .themeButton(isSelected: selectedTheme == index)
    }
    
    private func colorPreview() -> some View {
        VStack(spacing: 16) {
            Text("Önizleme")
                .font(.headline)
                .foregroundColor(.appText)
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor, secondaryColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                
                VStack {
                    Text("Örnek Metin Başlığı")
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    Text("Bu bir örnek açıklama metnidir")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    HStack(spacing: 16) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 40, height: 40)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appCard)
                            .frame(width: 150, height: 30)
                    }
                    .padding(.top, 12)
                }
            }
        }
    }
    
    private func applyTheme(index: Int) {
        // ThemeManager'ı kullanarak temayı direkt uygula
        themeManager.applyTheme(index: index)
        
        // Yerel durum değişkenlerini güncelle
        primaryColor = themeManager.primaryColor
        secondaryColor = themeManager.secondaryColor
        accentColor = themeManager.accentColor
    }
    
    private func applyCustomTheme() {
        // ThemeManager'ı kullanarak özel renkleri direkt uygula
        themeManager.applyCustomColors(
            primary: primaryColor,
            secondary: secondaryColor,
            accent: accentColor
        )
        
        // Tema seçilmediğini belirt
        selectedTheme = 0
    }
} 