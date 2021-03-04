
import SwiftUI

fileprivate let homeKitStore: HomeKitStore = .init()

struct ContentView: View {
    var body: some View {
        NavigationView {
            HomesListScreenViewContainer()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(homeKitStore)
        .onAppear {
            homeKitStore.load()
        }
    }
}
