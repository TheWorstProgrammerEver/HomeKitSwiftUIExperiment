
import HomeKit
import SwiftUI

struct HomeScreenViewContainer : View {
    
    var homeId: UUID
    
    @EnvironmentObject private var homeKitStore: HomeKitStore
    
    var body: some View {
        ViewContainer(
            HomeScreenModel(homeKitStore, homeId: homeId),
            HomeScreen.init)
            .navigationTitle("Edit")
    }
}

struct HomeScreen : View {

    @ObservedObject var model: HomeScreenModel
    
    var body: some View {
        List {
            Section(header: HStack {
                Text("Accessories")
                Spacer()
                Button(action: addAccessory) {
                    Text("Add")
                }
            }) {
                ForEach(model.details.accessories, id: \.id) { a in
                    Text(a.name)
                }
            }
        }
        .navigationTitle(model.details.name)
        .sheet(isPresented: availableAccessoriesPresentationBinding, onDismiss: model.reload) {
            AvailableAccessoriesModal(model: model)
        }
        .onDisappear {
            model.stop()
        }
    }
    
    private var availableAccessoriesPresentationBinding: Binding<Bool> {
        .init(
            get: { !model.availableAccessories.isEmpty },
            set: { v in
                if !v {
                    model.stop()
                }
            })
    }
    
    private func addAccessory() {
        model.addAccessory()
    }
}

fileprivate struct AvailableAccessoriesModal : View {
    
    @ObservedObject var model: HomeScreenModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.availableAccessories, id: \.uniqueIdentifier) { a in
                    Button(action: { model.confirmAccessory(a) }) {
                        Text(a.name)
                    }
                }
            }
            .navigationTitle("Accessories")
            .toolbar {
                Button(action: dismiss) {
                    Text("Done")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

class HomeScreenModel : NSObject, ObservableObject, HMAccessoryBrowserDelegate {
    
    @Published var details: HomeDetails
    
    // NOTE: All this stuff around searching for / adding accessories is a bit dirty, but I ran out of time to do this nicely.
    @Published var availableAccessories: [HMAccessory] = []
    
    
    private let homeKitStore: HomeKitStore
    
    private var browser: HMAccessoryBrowser!
    
    init(
        _ homeKitStore: HomeKitStore,
        homeId: UUID) {
        self.homeKitStore = homeKitStore
        
        let home = homeKitStore
            .homes
            .first { h in h.uniqueIdentifier == homeId }!
        
        self.details = .init(id: home.uniqueIdentifier, name: home.name, accessories: home.accessories.map { a in .init(id: a.uniqueIdentifier, name: a.name) } )
        
        super.init()
    }
    
    // Bit dirty here too. Soz.
    func reload() {
        let home = homeKitStore
            .homes
            .first { h in h.uniqueIdentifier == details.id }!
        
        details = .init(id: home.uniqueIdentifier, name: home.name, accessories: home.accessories.map { a in .init(id: a.uniqueIdentifier, name: a.name) } )
    }
    
    func addAccessory() {
        if browser == nil {
            browser = .init()
            browser.delegate = self
        }
        
        browser.stopSearchingForNewAccessories()
        
        browser.startSearchingForNewAccessories()
    }
    
    func confirmAccessory(_ accessory: HMAccessory) {
        homeKitStore.addAccessory(accessory, to: details.id)
    }
    
    func stop() {
        availableAccessories = []
        
        if browser == nil { return }
        
        browser.stopSearchingForNewAccessories()
        browser.delegate = nil
        browser = nil
    }
    
    private func maintainDetails(_ homeId: UUID) {
        homeKitStore
            .$homes
            .compactMap { homes in homes.first { h in h.uniqueIdentifier == homeId } }
            .map { home in
                .init(id: home.uniqueIdentifier, name: home.name, accessories: home.accessories.map { a in .init(id: a.uniqueIdentifier, name: a.name) } )
            }
            .assign(to: &$details)
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        
//        if details.accessories.contains(where: { a in a.id == accessory.uniqueIdentifier }) { return }
        
        availableAccessories.append(accessory)
    }
}

struct HomeDetails {
    var id: UUID
    var name: String
    var accessories: [Accessory]
    
    struct Accessory {
        var id: UUID
        var name: String
    }
}
