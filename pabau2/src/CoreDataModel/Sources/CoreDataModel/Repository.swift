import Model
import ComposableArchitecture
import Combine
import Util
import CoreStore

public final class Repository {
	
	public let journeyAPI: JourneyAPI
	public let clientAPI: ClientsAPI
	public let formAPI: FormAPI
	public let coreDataModel: CoreDataModel
	
	public init(
		journeyAPI: JourneyAPI,
		clientAPI: ClientsAPI,
		formAPI: FormAPI,
		userDefaults: UserDefaultsConfig,
		coreDataModel: CoreDataModel
	) {
		self.journeyAPI = journeyAPI
		self.clientAPI = clientAPI
		self.formAPI = formAPI
		self.coreDataModel = coreDataModel
	}
	
	public struct BookoutReasonsResponse: Equatable {
		public let isDB: Bool
		public let value: [BookoutReason]
	}
	
	public func getBookoutReasons() -> Effect<BookoutReasonsResponse, RequestError> {
		fatalError("TODO YURII")
	}
	//    public func getBookoutReasons() -> Effect<BookoutReasonsResponse, RequestError> {
	//        Effect<BookoutReasonsResponse, RequestError>.future { [weak self] callback in
	//            guard let self = self else {
	//                return
	//            }
	//
	//			let countDB = self.coreDataModel.fetchCount(BookoutReasonScheme.self)
	//
	//            if countDB == 0 {
	//                self.clientAPI.getBookoutReasons().result { result in
	//                    result.success { value in
	//                        log("Success. Got from Server")
	//                        value.forEach { $0.save(to: self.coreDataModel) }
	//                        callback(.success(BookoutReasonsResponse(isDB: false, value: value)))
	//                    }
	//                    result.failure { error in
	//                        log(error)
	//						callback(.failure(error))
	//					}
	//				}.store(in: &self.cancellables)
	//			} else {
	//				self.coreDataModel.fetchAllSchemes(BookoutReasonScheme.self).result { result in
	//					result.success { schemes in
	//						log("Success. Got from CoreData")
	//						callback(.success(BookoutReasonsResponse(isDB: true, value: BookoutReason.convert(from: schemes))))
	//					}
	//					result.failure { error in
	//						log(error)
	//						callback(.failure(error))
	//					}
	//				}.store(in: &self.cancellables)
	//			}
	//        }
	//    }
	
	public func getLocations() -> Effect<SuccessState<[Location]>, RequestError> {
		let countDB = self.coreDataModel.fetchCount(LocationScheme.self)
		if let count = countDB, count > 0 {
			return self.coreDataModel.fetchAllSchemes(LocationScheme.self)
				.map(Location.convert(from:))
				.map { SuccessState.db($0) }
		} else {
			return self.journeyAPI.getLocations()
				.map { SuccessState.api($0) }
		}
	}
	
	public func getEmployees() -> Effect<[Employee], RequestError> {
		fatalError("TODO YURII")
	}
	//public func getEmployees() -> Effect<[Employee], RequestError> {
	//	Effect<[Employee], RequestError>.future { [weak self] callback in
	//		guard let self = self else {
	//                return
	//            }
	//
	//            let countDB = self.coreDataModel.fetchCount(EmployeeScheme.self)
	//
	//            if countDB == 0 {
	//                self.journeyAPI.getEmployees().result { result in
	//                    result.success { value in
	//                        log("Success. Got from Server")
	//                        value.forEach { $0.save(to: self.coreDataModel) }
	//                        callback(.success(value))
	//                    }
	//
	//                    result.failure { error in
	//                        log(error)
	//                        callback(.failure(error))
	//                    }
	//                }.store(in: &self.cancellables)
	//
	//                return
	//            }
	//
	//            self.coreDataModel.fetchAllSchemes(EmployeeScheme.self).result { result in
	//                result.success { schemes in
	//                    log("Success. Got from CoreData")
	//                    callback(.success(Employee.convert(from: schemes)))
	//                }
	//                result.failure { error in
	//                    log(error)
	//                    callback(.failure(error))
	//                }
	//            }.store(in: &self.cancellables)
	//        }
	//    }
	//
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError> {
		fatalError("TODO YURII")
	}
	//    public func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError> {
	//        Effect<[FormTemplateInfo], RequestError>.future { [weak self] callback in
	//            guard let self = self else {
	//                return
	//            }
	//
	//            let countDB = try? self.coreDataModel.dataStack.fetchCount(
	//                From(FormTemplateInfoScheme.self),
	//                Where<FormTemplateInfoScheme>("%K > %d", "type", type.rawValue)
	//            )
	//
	//            if countDB == nil || countDB == 0 {
	//                self.formAPI.getTemplates(type).result { result in
	//                    result.success { value in
	//                        value.forEach { $0.save(to: self.coreDataModel) }
	//                        callback(.success(value))
	//                    }
	//                    result.failure { error in
	//                        log(error)
	//                        callback(.failure(error))
	//                    }
	//                }.store(in: &self.cancellables)
	//            }
	//
	//            self.coreDataModel.fetchAllSchemes(FormTemplateInfoScheme.self).result { result in
	//                result.success { schemes in
	//                    log("Success. Got from CoreData")
	//                    callback(.success(FormTemplateInfo.convert(from: schemes)))
	//                }
	//                result.failure { error in
	//                    log(error)
	//                    callback(.failure(error))
	//                }
	//            }.store(in: &self.cancellables)
	//        }
	//    }
	
	public func getPathwayTemplates() -> Effect<IdentifiedArrayOf<PathwayTemplate>, RequestError> {
		fatalError("TODO YURII")
	}
	
	//    public func getPathwayTemplates() -> Effect<IdentifiedArrayOf<PathwayTemplate>, RequestError> {
	//        Effect<IdentifiedArrayOf<PathwayTemplate>, RequestError>.future { [weak self] callback in
	//            guard let self = self else {
	//                return
	//            }
	//
	//            let countDB = self.coreDataModel.fetchCount(PathwayTemplateScheme.self)
	//
	//            if countDB == 0 {
	//                self.journeyAPI.getPathwayTemplates().result { result in
	//                    result.success { value in
	//                        value.forEach { $0.save(to: self.coreDataModel) }
	//                        callback(.success(value))
	//                    }
	//                    result.failure { error in
	//                        log(error)
	//                        callback(.failure(error))
	//                    }
	//                }.store(in: &self.cancellables)
	//            }
	//
	//            self.coreDataModel.fetchAllSchemes(PathwayTemplateScheme.self).result { result in
	//                result.success { schemes in
	//                    log("Success. Got from CoreData")
	//                    callback(.success(PathwayTemplate.convert(from: schemes)))
	//                }
	//                result.failure { error in
	//                    log(error)
	//                    callback(.failure(error))
	//                }
	//            }.store(in: &self.cancellables)
	//        }
	//    }
	//
}

