import Foundation

struct RecognizedItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let confidence: Float
    let suggestedCategories: [String]
    
    init(name: String, confidence: Float, suggestedCategories: [String] = []) {
        self.name = name
        self.confidence = confidence
        self.suggestedCategories = suggestedCategories
    }
}
