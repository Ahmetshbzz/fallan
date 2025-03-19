import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void
    var startColor: Color = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    var endColor: Color = Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
    var iconName: String?
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [startColor, endColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: endColor.opacity(0.5), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).ignoresSafeArea()
        
        VStack(spacing: 20) {
            GradientButton(title: "Fotoğraf Seç", action: {})
            
            GradientButton(
                title: "Analiz Et", 
                action: {},
                iconName: "sparkles"
            )
            
            GradientButton(
                title: "İptal", 
                action: {},
                startColor: Color.red.opacity(0.7),
                endColor: Color.red
            )
        }
    }
} 