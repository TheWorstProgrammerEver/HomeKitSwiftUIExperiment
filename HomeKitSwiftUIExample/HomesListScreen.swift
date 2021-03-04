
import SwiftUI

struct HomesListScreenViewContainer : View {
    
    @EnvironmentObject private var homeKitStore: HomeKitStore
    
    var body: some View {
        ViewContainer(
            HomesListScreenModel(homeKitStore),
            HomesListScreen.init)
            .navigationTitle("Homes")
    }
}

struct HomesListScreen : View {
    
    @ObservedObject var model: HomesListScreenModel
    
    @State private var selectedHome: UUID? = nil
    
    var body: some View {
        List {
            Section(header: HStack {
                Text("Homes")
                Spacer()
                Button(action: addHome) { Text("Add") }
            }) {
                ForEach(model.homes, id: \.id) { h in
                    NavigationLink(
                        destination: HomeScreenViewContainer(homeId: h.id),
                        tag: h.id,
                        selection: $selectedHome) {
                        Text(h.name)
                    }
                }
            }
        }
    }
    
    private func addHome() {
        model.addHome()
    }
}

class HomesListScreenModel : ObservableObject {
    
    @Published var homes: [HomeListItem] = []
    
    private let homeKitStore: HomeKitStore
    
    init(_ homeKitStore: HomeKitStore) {
        self.homeKitStore = homeKitStore
        
        maintainHomes()
    }
    
    func addHome() {
        homeKitStore.addHome()
    }
    
    private func maintainHomes() {
        homeKitStore
            .$homes
            .map { homes in
                homes.map { h in .init(id: h.uniqueIdentifier, name: h.name) }
            }
            .assign(to: &$homes)
    }
}

struct HomeListItem {
    var id: UUID
    var name: String
}
