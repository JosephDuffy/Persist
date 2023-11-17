//#if canImport(SwiftUI) && canImport(Combine)
//import Combine
//import SwiftUI
//
///// A wrapper around ``Persister`` that inherits from ``ObservableObject``.
//@available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
//public final class ObservablePersister<Value>: ObservableObject {
//    @Published
//    public private(set) var value: Value
//
//    /// The persister used to persist and retrieve the stored value.
//    internal let persister: Persister<Value>
//
//    private var valueCancellable: Combine.AnyCancellable?
//
//
//    /// Create a new instance that uses the provided ``Persister`` to persist and retrieve the value.
//    public init(persister: Persister<Value>) {
//        self.persister = persister
//        value = persister.retrieveValue()
//        valueCancellable = persister.updatesPublisher.sink { [weak self] result in
//            switch result {
//            case .success(let update):
//                self?.value = update.newValue
//            case .failure:
//                break
//            }
//        }
//    }
//}
//#endif
