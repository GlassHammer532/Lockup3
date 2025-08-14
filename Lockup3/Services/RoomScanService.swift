import RoomPlan
import ARKit
import SwiftUI

@MainActor
final class RoomScanService: NSObject, ObservableObject {
    @Published var capturedRoomData: CapturedRoomData?
    @Published var finalRoomResult: CapturedRoom?
    @Published var isScanning = false
    @Published var scanProgress: Float = 0.0
    
    private var captureSession: RoomCaptureSession?
    
    func startScanning() {
        guard RoomCaptureSession.isSupported else {
            print("RoomPlan not supported on this device")
            return
        }
        
        captureSession = RoomCaptureSession()
        captureSession?.delegate = self
        
        let configuration = RoomCaptureSession.Configuration()
        configuration.isCoachingEnabled = true
        
        captureSession?.run(configuration: configuration)
        isScanning = true
    }
    
    func stopScanning() {
        captureSession?.stop()
        isScanning = false
    }
    
    func processRoomData() async throws -> Data? {
        guard let capturedData = capturedRoomData else { return nil }
        
        let roomBuilder = RoomBuilder(options: [.beautifyObjects])
        let finalRoom = try await roomBuilder.capturedRoom(from: capturedData)
        
        await MainActor.run {
            self.finalRoomResult = finalRoom
        }
        
        // Serialize room data for storage
        return try JSONEncoder().encode(finalRoom)
    }
}

extension RoomScanService: RoomCaptureSessionDelegate {
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        Task { @MainActor in
            finalRoomResult = room
        }
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
        Task { @MainActor in
            capturedRoomData = data
            isScanning = false
            
            if let error = error {
                print("Capture ended with error: \(error)")
                return
            }
        }
    }
}
