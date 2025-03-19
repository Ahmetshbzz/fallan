import SwiftUI
import Foundation

class GeminiService {
    // API anahtarınızı Settings.bundle veya başka bir güvenli yöntemle saklamanız önerilir
    private var apiKey: String {
        // Gerçek API anahtarınızı buraya ekleyin
        let key = "AIzaSyDBA4QdAMjBNWbHjqGn5rNAOKAPNeH_LZw"
        
        // Test amacıyla sahte yanıt vermek için kontrol
        if key == "YOUR_GEMINI_API_KEY" {
            print("⚠️ Gerçek bir Gemini API anahtarı tanımlanmamış! Test yanıtı döndürülüyor.")
            return ""  // Boş anahtar döndür, test moduna geçilecek
        }
        return key
    }
    
    // 2025 yılında en güncel model - Gemini 2.0 Flash
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    func analyzeImage(_ imageData: Data) async throws -> String {
        // Test modu kontrolü
        if apiKey.isEmpty {
            return generateTestResponse()
        }
        
        // Base64 formatına dönüştürme
        let base64EncodedImage = imageData.base64EncodedString()
        
        // API URL oluşturma
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("⚠️ API URL oluşturulamadı")
            throw NetworkError.invalidURL
        }
        
        // JSON verisi
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Bu fotoğrafa bakarak bana bir kehanet veya astrolojik bir yorum söyler misin?"],
                        ["inlineData": [
                            "mimeType": "image/jpeg",
                            "data": base64EncodedImage
                        ]]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "topK": 32,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            // HTTP isteği oluşturma
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // API isteği gönderme
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Yanıtı kontrol etme
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ HTTP yanıtı alınamadı")
                throw NetworkError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                print("⚠️ HTTP yanıtı başarısız: \(httpResponse.statusCode)")
                if let errorStr = String(data: data, encoding: .utf8) {
                    print("Hata detayı: \(errorStr)")
                }
                throw NetworkError.invalidResponse
            }
            
            // Yanıtı işleme
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text
            } else {
                print("⚠️ API yanıtı işlenemedi")
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("API yanıtı: \(responseStr)")
                }
                throw NetworkError.invalidData
            }
        } catch {
            print("⚠️ İstek sırasında hata: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Test amaçlı sahte yanıt
    private func generateTestResponse() -> String {
        let testResponses = [
            "Bu fotoğrafta gördüğüm detaylar çarpıcı. Aura'nızda parlak mavi ve mor tonlar görüyorum, bu da yaratıcı ve sezgisel enerjilerinizin yükselişte olduğunu gösteriyor. Önünüzdeki haftalarda beklenmedik bir karşılaşma yaşayabilirsiniz ve bu, uzun vadeli hedeflerinizi olumlu yönde etkileyecek bir dönüm noktası olabilir.",
            
            "Fotoğrafınızda Jüpiter etkisi çok belirgin! Bu, önümüzdeki 3 ay içinde genişleme ve büyüme fırsatlarıyla karşılaşacağınızı gösteriyor. Hayatınızda şu anda ertelediğiniz bir proje veya fikir varsa, şimdi harekete geçmek için mükemmel bir zaman. Çevrenizdeki kişilerden beklemediğiniz bir destek görebilirsiniz.",
            
            "Enerji alanınız şu anda dönüşüm sürecinde. Fotoğrafta görünen titreşimler, yakın zamanda bir döngüyü tamamladığınızı ve yeni bir başlangıç aşamasına geçtiğinizi gösteriyor. Önümüzdeki ayda su elementinin etkisi altında olacaksınız, bu nedenle duygusal kararlar vermeden önce iki kez düşünmenizi öneririm.",
            
            "Bu görüntüdeki enerjik imza, yaşam amacınızla güçlü bir şekilde bağlantı kurduğunuzu gösteriyor. Mars'ın mevcut konumu, cesaretinizi ve kararlılığınızı artırıyor. Uzun süredir ertelediğiniz bir hayali gerçekleştirmek için önünüzde beklenmedik bir fırsat belirdiğinde şaşırmayın. İçgüdülerinize güvenin.",
            
            "Fotoğrafınızda Venüs'ün güçlü etkisini hissediyorum. Yakın gelecekte ilişkiler ve ortaklıklar konusunda olumlu gelişmeler yaşayabilirsiniz. Ayrıca maddi konularda bir iyileşme görünüyor. Şu anda etrafınızda yeşil bir enerji alanı var, bu da büyüme ve sağlık açısından olumlu bir dönemde olduğunuzu gösteriyor."
        ]
        
        return testResponses.randomElement() ?? testResponses[0]
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
} 