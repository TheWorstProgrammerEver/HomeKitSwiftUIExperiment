
import HomeKit
import Combine

class HomeKitStore : NSObject, ObservableObject, HMHomeManagerDelegate {
    
    @Published var homes: [HMHome] = []
    
    private var manager: HMHomeManager!
    
    func load() {
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        // NOTE: RH - Pretty sure this delegate method is meant to be called after we addHome(withName:...) but it doesn't.
        homes = manager.homes
    }
    
    func addHome() {
        manager.addHome(withName: "Random-\(UUID())") { [weak self] (_, _) in
            // Don't care about possible errors... Assume it works.
            
            // NOTE: RH - Because the homeManagerDidUpdateHomes method isn't getting invoked, I suppose we'll just manually invoke it...
            guard let self = self else { return }
            
            self.homeManagerDidUpdateHomes(self.manager)
        }
    }
    
    func addAccessory(_ accessory: HMAccessory, to homeId: UUID) {
        homes.first { h in h.uniqueIdentifier == homeId }!.addAccessory(accessory) { _ in
            // Don't care about possible errors... Assume it works.
        }
    }
}
