import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Text("Welcome to Lockup")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
