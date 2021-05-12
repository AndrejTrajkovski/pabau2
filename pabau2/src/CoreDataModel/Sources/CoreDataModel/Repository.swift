import Model
import ComposableArchitecture
import Combine
import Util

public final class Repository {

    public let journeyAPI: JourneyAPI
    public let clientAPI: ClientsAPI
    public let coreDataModel: CoreDataModel
    
    var cancellables = Set<AnyCancellable>()
    
    public init(
        journeyAPI: JourneyAPI,
        clientAPI: ClientsAPI,
        userDefaults: UserDefaultsConfig,
        coreDataModel: CoreDataModel
    ) {
        self.journeyAPI = journeyAPI
        self.clientAPI = clientAPI
        self.coreDataModel = coreDataModel
    }
    
    public struct BookoutReasonsResponse: Equatable {
        public let isDB: Bool
        public let value: [BookoutReason]
    }
    public func getBookoutReasons() -> Effect<BookoutReasonsResponse, RequestError> {
        return Effect<BookoutReasonsResponse, RequestError>.future { [weak self] callback in
            guard let self = self else {
                return
            }
            
            let countDB = self.coreDataModel.fetchCount(BookoutReasonScheme.self)

            if countDB == 0 {
                log(countDB, text: "DB Empty")
                self.clientAPI.getBookoutReasons().sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            log(error)
                            callback(.failure(error))
                        case .finished:
                            log("Success. Got from Server")
                        }
                    },
                    receiveValue: { value in
                        value.forEach { $0.save(to: self.coreDataModel) }
                        callback(.success(BookoutReasonsResponse(isDB: false, value: value)))
                    }
                ).store(in: &self.cancellables)
                
                return
            }
      
            self.coreDataModel.fetchAllSchemes(BookoutReasonScheme.self).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        log(error)
                        callback(.failure(error))
                    case .finished:
                        log("Success. Got from CoreData")
                    }
                },
                receiveValue: { schemes in
                    callback(.success(BookoutReasonsResponse(isDB: true, value: BookoutReason.convert(from: schemes))))
                }
            ).store(in: &self.cancellables)
        }
    }
    
    public func getEmployees() -> Effect<[Employee], RequestError> {
        return Effect<[Employee], RequestError>.future { [weak self] callback in
            guard let self = self else {
                return
            }
            
            let countDB = self.coreDataModel.fetchCount(EmployeeScheme.self)
            
            if countDB == 0 {
                log(countDB, text: "DB Empty")
                self.journeyAPI.getEmployees().sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            log(error)
                            callback(.failure(error))
                        case .finished:
                            log("Success. Got from Server")
                        }
                    },
                    receiveValue: { value in
                        value.forEach { $0.save(to: self.coreDataModel) }
                        callback(.success(value))
                    }
                ).store(in: &self.cancellables)
                
                return
            }
            
            self.coreDataModel.fetchAllSchemes(EmployeeScheme.self).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        log(error)
                        callback(.failure(error))
                    case .finished:
                        log("Success. Got from CoreData")
                    }
                },
                receiveValue: { schemes in
                    callback(.success(Employee.convert(from: schemes)))
                }
            ).store(in: &self.cancellables)
        }
    }
}
