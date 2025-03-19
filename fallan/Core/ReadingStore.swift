import Foundation
import SwiftUI

class ReadingStore: ObservableObject {
    @Published var readings: [Reading] = []
    private let userDefaultsKey = "savedReadings"
    
    init() {
        loadReadings()
    }
    
    func saveReading(_ content: String, imageData: Data) -> Reading {
        // Görüntü verilerini dokümanlara kaydetme
        let imageID = UUID().uuidString
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("\(imageID).jpg")
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Görüntü kaydedilirken hata oluştu: \(error.localizedDescription)")
        }
        
        // Yeni yorumu oluşturma ve kaydetme
        let newReading = Reading(content: content, imageID: imageID)
        readings.insert(newReading, at: 0)
        saveReadings()
        
        return newReading
    }
    
    func getImage(for reading: Reading) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("\(reading.imageID).jpg")
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Görüntü yüklenirken hata oluştu: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteReading(_ reading: Reading) {
        // Diziden silme
        if let index = readings.firstIndex(where: { $0.id == reading.id }) {
            readings.remove(at: index)
        }
        
        // Görüntüyü disk üzerinden silme
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("\(reading.imageID).jpg")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Görüntü silinirken hata oluştu: \(error.localizedDescription)")
        }
        
        saveReadings()
    }
    
    private func saveReadings() {
        if let encodedData = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadReadings() {
        guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decodedReadings = try? JSONDecoder().decode([Reading].self, from: savedData) else {
            return
        }
        
        readings = decodedReadings
    }
} 