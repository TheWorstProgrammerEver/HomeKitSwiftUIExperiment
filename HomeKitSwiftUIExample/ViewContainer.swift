
import SwiftUI

// Until there's some better way to initialize parameterised @StateObjects,
// we'll encapsulate the dirt around .onAppear

fileprivate class ModelContainer<T> : ObservableObject {
    
    @Published private(set) var model: T? = nil
    
    func load(_ t: T) {
        model = t
    }
}

struct ViewContainer<Model, Content> : View where Content : View {
    
    @StateObject private var modelContainer: ModelContainer<Model> = .init()
    
    private let modelInitializer: () -> Model
    private let content: (Model) -> Content
    
    init(
        modelInitializer: @escaping () -> Model,
        @ViewBuilder content: @escaping (Model) -> Content) {
        
        self.content = content
        self.modelInitializer = modelInitializer
    }
    
    init(
        _ modelInitializer: @autoclosure @escaping () -> Model,
        @ViewBuilder _ content: @escaping (Model) -> Content) {
        self.init(modelInitializer: modelInitializer, content: content)
    }
    
    @ViewBuilder var body: some View {
        switch modelContainer.model {
        
        case .some(let model):
            content(model)
            
        case .none:
            Color.clear
                .onAppear {
                    modelContainer.load(modelInitializer())
                }
        }
    }
}
