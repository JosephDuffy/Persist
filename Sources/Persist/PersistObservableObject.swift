#if canImport(SwiftUI)
import Combine
import SwiftUI

@available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
public final class PersistObservableObject<Value>: ObservableObject {
    @Published
    public private(set) var value: Value

    internal let persister: Persister<Value>

    private var valueCancellables: Combine.AnyCancellable?

    /**
     Create a new instance that uses the provided `Persister` to persist and retrieve the value.
     */
    public init(persister: Persister<Value>) {
        self.persister = persister
        value = persister.retrieveValue()
        valueCancellables = persister.updatesPublisher.sink { [weak self] result in
            switch result {
            case .success(let update):
                self?.value = update.newValue
            case .failure:
                break
            }
        }
    }
}
#endif
