import ComposableArchitecture
import CoreStore
import Combine
import Model
// https://github.com/JohnEstropia/CoreStore

public protocol CoreDataModel {
	var dataStack: DataStack { get }
	
	func initialized()
	func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], RequestError>
	func fetchCount<T: DynamicObject>(_ type: T.Type) -> Int?
	func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, RequestError>
	func removeAll() -> Effect<(), RequestError>
	
//	public func saveGames(
//	  games: SavedGamesState, on queue: AnySchedulerOf<DispatchQueue>
//	) -> Effect<Never, Never> {
//	  self.save(games, to: savedGamesFileName, on: queue)
//	}
//
//	public func save<A: Encodable>(
//	  _ data: A, to fileName: String, on queue: AnySchedulerOf<DispatchQueue>
//	) -> Effect<Never, Never> {
//	  Just(data)
//		.subscribe(on: queue)
//		.encode(encoder: JSONEncoder())
//		.flatMap { data in self.save(fileName, data) }
//		.ignoreFailure()
//		.eraseToEffect()
//	}
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
	
	public func fetchAllSchemes<T: DynamicObject>(_ type: T.Type) -> Effect<[T], RequestError>  {
		Effect<[T], RequestError>.future { [weak self] callback in
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
						callback(.failure(RequestError.coreData($0.coreStoreDumpString)))
					}
				}
			)
		}
	}
	
	public func removeAll<T: DynamicObject>(_ type: T.Type) -> Effect<Int, RequestError> {
		Effect<Int, RequestError>.future { [weak self] callback in
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
						callback(.failure(RequestError.coreData($0.coreStoreDumpString)))
					}
				}
			)
		}
	}
	
	public func removeAll() -> Effect<(), RequestError> {
		Effect<(), RequestError>.future { [weak self] callback in
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
						callback(.failure(RequestError.coreData($0.coreStoreDumpString)))
					}
				}
			)
		}
	}
	
	public func fetchCount<T: DynamicObject>(_ type: T.Type) -> Int? {
		do {
			let count = try self.dataStack.fetchCount(From(type))
			return count
		} catch {
//			log(error)
			return nil
		}
	}
}
