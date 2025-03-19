import SwiftUI
import Foundation

class GeminiService {
    private let apiKey: String = "AIzaSyDBA4QdAMjBNWbHjqGn5rNAOKAPNeH_LZw" // Gemini API anahtarınızı buraya ekleyin
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"
    
    func analyzeImage(_ imageData: Data) async throws -> String {
        // Base64 formatına dönüştürme
        let base64EncodedImage = imageData.base64EncodedString()
        
        // API URL oluşturma
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
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
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // HTTP isteği oluşturma
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // API isteği gönderme
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Yanıtı kontrol etme
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
            throw NetworkError.invalidData
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
} 