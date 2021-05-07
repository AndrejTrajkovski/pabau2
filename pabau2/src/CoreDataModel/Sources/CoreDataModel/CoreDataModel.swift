import Util
import ComposableArchitecture
import CoreStore
// https://github.com/JohnEstropia/CoreStore

public protocol CoreDataModel {
     var dataStack: DataStack { get }
    
     func initialized()
     func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], CoreDataModelError>
     func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, CoreDataModelError>
     func removeAll() -> Effect<(), CoreDataModelError>
}

public class PabauStorage: CoreDataModel {
    public init() {}
    
    public var dataStack = DataStack(
        CoreStoreSchema(
            modelVersion: "V1",
            entities: [
                Entity<BookoutReasonScheme>("BookoutReasonScheme"),
                Entity<PathwayTemplateScheme>("PathwayTemplateScheme"),
                Entity<LocationScheme>("LocationScheme"),
                Entity<FormTemplateInfoScheme>("FormTemplateInfoScheme"),
                Entity<IDsScheme>("EmployeeScheme_IDsScheme"),
                Entity<StepScheme>("StepScheme"),
                Entity<EmployeeScheme>("EmployeeScheme")
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

    public func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], CoreDataModelError>  {
         Effect<[T], CoreDataModelError>.future { [weak self] callback in
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
                        callback(.failure(CoreDataModelError.dumpError($0.coreStoreDumpString)))
                    }
                }
            )
        }
    }
    
    public func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, CoreDataModelError> {
        Effect<Int, CoreDataModelError>.future { [weak self] callback in
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
                        callback(.failure(CoreDataModelError.dumpError($0.coreStoreDumpString)))
                    }
                }
            )
        }
    }
    
    public func removeAll() -> Effect<(), CoreDataModelError> {
        Effect<(), CoreDataModelError>.future { [weak self] callback in
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
                    result.success { callback(.success(()) ) }
                    result.failure {
                        callback(.failure(CoreDataModelError.dumpError($0.coreStoreDumpString)))
                    }
                }
            )
        }
    }
}

public enum CoreDataModelError: Error, Equatable, CustomStringConvertible {
    public static func == (lhs: CoreDataModelError, rhs: CoreDataModelError) -> Bool {
        switch (lhs, rhs) {
        case (.dumpError, .dumpError):
            return true
        }
    }

    case dumpError(String)
  
    public var description: String {
        switch self {
        case .dumpError(let message):
            return message
        }
    }
}
