import SwiftUI

// Ana buton stili
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.appText)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.appAccent)
                    .shadow(color: Color.appAccent.opacity(0.3), radius: 5, x: 0, y: 3)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// İkincil buton stili
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.appText)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.appAccent.opacity(0.7), lineWidth: 1.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Simge butonu stili
struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.appText)
            .padding()
            .background(
                Circle()
                    .fill(Color.appAccent.opacity(0.3))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// ViewModifier uzantısı
extension View {
    // Ana buton stili
    func appPrimaryButton() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    // İkincil buton stili
    func appSecondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    // Simge buton stili
    func appIconButton() -> some View {
        self.buttonStyle(IconButtonStyle())
    }
}

// Tema sayfaları için özel modifierlar
extension Button {
    // Tema seçim butonu
    func themeButton(isSelected: Bool) -> some View {
        self.overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appText, lineWidth: 3)
                }
            }
        )
    }
} 