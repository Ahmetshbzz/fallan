import SwiftUI

struct InfoCard: View {
    let title: String
    let description: String
    var iconName: String
    var backgroundColor: Color = Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)).opacity(0.2)
    var iconColor: Color = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct InfoCardView: View {
    var body: some View {
        VStack(spacing: 15) {
            InfoCard(
                title: "Fotoğraf Yükle",
                description: "İstediğin bir fotoğrafı seç ve astrolojik yorumunu al.",
                iconName: "photo.on.rectangle.angled"
            )
            
            InfoCard(
                title: "AI Analizi",
                description: "Yapay zeka fotoğrafını analiz edip kişisel yorumlar üretir.",
                iconName: "sparkles",
                backgroundColor: Color.blue.opacity(0.2),
                iconColor: Color.blue
            )
            
            InfoCard(
                title: "Geçmiş Yorumlar",
                description: "Önceki yorumlarına istediğin zaman geri dönebilirsin.",
                iconName: "clock.arrow.circlepath",
                backgroundColor: Color.orange.opacity(0.2),
                iconColor: Color.orange
            )
        }
        .padding()
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).ignoresSafeArea()
        InfoCardView()
    }
} 