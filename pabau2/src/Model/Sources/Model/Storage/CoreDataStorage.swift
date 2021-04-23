import CoreStore
import Util
import ComposableArchitecture
// https://github.com/JohnEstropia/CoreStore

public protocol CoreDataStorage {
     var dataStack: DataStack { get }
    
     func initialized()
     func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], CoreStoreError>
     func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, CoreStoreError>
     func removeAll() -> Effect<(), CoreStoreError>
}

public class PabauStorage: CoreDataStorage {
    
    public init() {}
    
    public var dataStack = DataStack(
        CoreStoreSchema(
            modelVersion: "V1",
            entities: [
                Entity<BookoutReasonScheme>("BookoutReasonScheme")
            ]
        )
    )
    
    public func initialized() {
        _ = dataStack.addStorage(
            SQLiteStore(
                fileName: "pubau2.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        ) { result in
            print(result)
        }
    }
    
    public func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], CoreStoreError>  {
         Effect<[T], CoreStoreError>.future { [weak self] callback in
            guard let self = self else {
                return
            }
            
            self.dataStack.perform(
                asynchronous: { transaction in
                   try transaction.fetchAll(From<T>())
                },
                completion: { result in
                    result.success {
                        callback(.success(self.dataStack.fetchExisting($0)))
                    }
                    result.failure {
                        callback(.failure($0))
                    }
                }
            )
        }
    }
    
    public func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, CoreStoreError> {
        Effect<Int, CoreStoreError>.future { [weak self] callback in
            guard let self = self else {
                return
            }
            
            self.dataStack.perform(
                asynchronous: { transaction in
                    try transaction.deleteAll(From<T>())
                },
                completion: { result in
                    result.success {
                        callback(.success($0))
                    }
                    result.failure {
                        callback(.failure($0))
                    }
                }
            )
        }
    }
    
    public func removeAll() -> Effect<(), CoreStoreError> {
        Effect<(), CoreStoreError>.future { [weak self] callback in
            self?.dataStack.perform(
                asynchronous: { [weak self] transaction in
                    guard let self = self else {
                        return
                    }
                    
                    do {
                        for (_, type) in self.dataStack.entityTypesByName(for: CoreStoreObject.self) {
                            try transaction.deleteAll(From(type))
                        }
                    } catch {}
                },
                completion: { result in
                    callback(result)
                }
            )
        }
    }
}



