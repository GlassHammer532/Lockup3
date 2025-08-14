import Foundation

struct Position3D: Codable {
    let x: Float
    let y: Float
    let z: Float
    let rotationX: Float
    let rotationY: Float
    let rotationZ: Float
    
    init(x: Float = 0, y: Float = 0, z: Float = 0, 
         rotationX: Float = 0, rotationY: Float = 0, rotationZ: Float = 0) {
        self.x = x
        self.y = y
        self.z = z
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
    }
}
