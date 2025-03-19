import SwiftUI

struct OnboardingView: View {
    @State private var showHome = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)), Color(#colorLiteral(red: 0.3647058904, green: 0, blue: 0.5176470876, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Yıldızlar efekti
            StarsView()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo ve başlık
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Fallan")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Fotoğraflardan Geleceğinizi Keşfedin")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Bilgi kartları
                InfoCardView()
                
                Spacer()
                
                // Başlangıç butonu
                GradientButton(
                    title: "Keşfetmeye Başla", 
                    action: {
                        withAnimation {
                            hasSeenOnboarding = true
                            showHome = true
                        }
                    },
                    iconName: "arrow.right"
                )
                .padding(.bottom, 40)
            }
            .fullScreenCover(isPresented: $showHome) {
                HomeView()
            }
        }
    }
}

struct StarsView: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeInterval = timeline.date.timeIntervalSinceReferenceDate
                let phase = timeInterval.truncatingRemainder(dividingBy: 10)
                
                context.opacity = 0.8
                
                // 50 yıldız çiz
                for i in 0..<50 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    
                    let hue = CGFloat.random(in: 0.5...0.8)
                    let saturation = CGFloat.random(in: 0.5...1)
                    let brightness = CGFloat.random(in: 0.8...1)
                    
                    let starSize = CGFloat.random(in: 1...3)
                    
                    let opacity = sin(phase + Double(i)) * 0.5 + 0.5
                    
                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: starSize, height: starSize)),
                        with: .color(Color(hue: hue, saturation: saturation, brightness: brightness))
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
} 