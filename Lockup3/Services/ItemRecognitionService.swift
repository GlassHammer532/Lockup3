import CoreML
import Vision
import UIKit

@MainActor
final class ItemRecognitionService: ObservableObject {
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var isProcessing = false
    
    private let visionQueue = DispatchQueue(label: "vision-queue", qos: .userInitiated)
    
    func recognizeItems(from images: [UIImage]) async throws -> [RecognizedItem] {
        isProcessing = true
        defer { isProcessing = false }
        
        var recognizedItems: [RecognizedItem] = []
        
        for image in images {
            let item = try await recognizeItem(from: image)
            recognizedItems.append(item)
        }
        
        return recognizedItems
    }
    
    private func recognizeItem(from image: UIImage) async throws -> RecognizedItem {
        guard let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: MobileNetV2().model)) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    continuation.resume(throwing: RecognitionError.noResults)
                    return
                }
                
                let suggestedCategories = self.generateCategorySuggestions(for: topResult.identifier)
                let item = RecognizedItem(
                    name: topResult.identifier,
                    confidence: topResult.confidence,
                    suggestedCategories: suggestedCategories
                )
                continuation.resume(returning: item)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            visionQueue.async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func generateCategorySuggestions(for itemName: String) -> [String] {
        // Simple category mapping - can be enhanced with ML
        let categoryMap: [String: [String]] = [
            "hammer": ["Tools", "Hardware"],
            "screwdriver": ["Tools", "Hardware"],
            "drill": ["Power Tools", "Tools"],
            "wrench": ["Tools", "Hardware"],
            "saw": ["Tools", "Cutting Tools"],
            "ladder": ["Safety Equipment", "Tools"],
            "helmet": ["Safety Equipment", "PPE"]
        ]
        
        return categoryMap[itemName.lowercased()] ?? ["General"]
    }
}

enum RecognitionError: Error {
    case invalidImage
    case noResults
    case modelLoadFailed
}
