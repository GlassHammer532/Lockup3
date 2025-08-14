import SwiftUI
import UIKit

@MainActor
@Observable
final class ItemCreateViewModel {
    var selectedImages: [UIImage] = []
    var recognizedItems: [RecognizedItem] = []
    var selectedLocation: StorageLocation?
    var isProcessing = false
    
    private let itemRepo: ItemRepository
    private let recognitionService: ItemRecognitionService
    
    init(itemRepo: ItemRepository = ItemRepository(),
         recognitionService: ItemRecognitionService = ItemRecognitionService()) {
        self.itemRepo = itemRepo
        self.recognitionService = recognitionService
    }
    
    func processImages() async {
        guard !selectedImages.isEmpty else { return }
        
        isProcessing = true
        
        do {
            recognizedItems = try await recognitionService.recognizeItems(from: selectedImages)
        } catch {
            print("Error recognizing items: \(error)")
        }
        
        isProcessing = false
    }
    
    func createItems() async -> Bool {
        guard let location = selectedLocation else { return false }
        
        do {
            let _ = try await itemRepo.bulkCreate(recognizedItems, in: location)
            return true
        } catch {
            print("Error creating items: \(error)")
            return false
        }
    }
    
    func updateItemName(_ item: RecognizedItem, newName: String) {
        if let index = recognizedItems.firstIndex(where: { $0.id == item.id }) {
            recognizedItems[index] = RecognizedItem(
                name: newName,
                confidence: item.confidence,
                suggestedCategories: item.suggestedCategories
            )
        }
    }
}
