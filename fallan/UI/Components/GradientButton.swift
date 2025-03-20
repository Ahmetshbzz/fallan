import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void
    var startColor: Color?
    var endColor: Color?
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
            .foregroundColor(.appText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            startColor ?? Color.appAccent,
                            endColor ?? Color.appAccent.opacity(0.7)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: (endColor ?? Color.appAccent).opacity(0.5), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).ignoresSafeArea()
        
        VStack {
            GradientButton(title: "Fotoğraf Seç", action: {})
            
            GradientButton(
                title: "Keşfetmeye Başla",
                action: {},
                iconName: "arrow.right"
            )
            
            GradientButton(
                title: "Özel Renk Butonu",
                action: {},
                startColor: .green,
                endColor: .blue,
                iconName: "sparkles"
            )
        }
    }
} 