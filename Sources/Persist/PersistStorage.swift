#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI

@available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
@propertyWrapper
public struct PersistStorage<Value>: DynamicProperty {
    public var wrappedValue: Value {
        get { observableObject.value }
        nonmutating set {
            try? observableObject.persister.persist(newValue)
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    public var persister: Persister<Value> {
        observableObject.persister
    }

    @ObservedObject
    private var observableObject: ObservablePersister<Value>

    public init(persister: Persister<Value>) {
        observableObject = ObservablePersister(persister: persister)
    }
}
#endif
