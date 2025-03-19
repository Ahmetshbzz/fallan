import SwiftUI

struct ReadingHistoryView: View {
    @ObservedObject var readingStore: ReadingStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReading: Reading?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)), Color(#colorLiteral(red: 0.3647058904, green: 0, blue: 0.5176470876, alpha: 1))]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if readingStore.readings.isEmpty {
                        emptyStateView
                    } else {
                        readingsList
                    }
                }
                .navigationTitle("Geçmiş Yorumlar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Kapat") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .sheet(item: $selectedReading) { reading in
                readingDetailView(for: reading)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Henüz yorum geçmişiniz yok")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Fotoğraflardan kehanet almak için ana sayfaya dönün")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                dismiss()
            } label: {
                Text("Ana Sayfaya Dön")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .shadow(radius: 5)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
    
    private var readingsList: some View {
        List {
            ForEach(readingStore.readings) { reading in
                readingRow(for: reading)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        selectedReading = reading
                    }
            }
            .onDelete(perform: deleteReading)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func readingRow(for reading: Reading) -> some View {
        HStack(spacing: 15) {
            if let image = readingStore.getImage(for: reading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(reading.content.prefix(50) + (reading.content.count > 50 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(formattedDate(reading.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private func readingDetailView(for reading: Reading) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let image = readingStore.getImage(for: reading) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                }
                
                ScrollView {
                    Text(reading.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Text(formattedDate(reading.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Button {
                    selectedReading = nil
                } label: {
                    Text("Kapat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)).opacity(0.7))
                        )
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }
    
    private func deleteReading(at offsets: IndexSet) {
        for index in offsets {
            readingStore.deleteReading(readingStore.readings[index])
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

#Preview {
    ReadingHistoryView(readingStore: ReadingStore())
} 