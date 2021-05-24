import Model
import ComposableArchitecture
import Combine
import Util
import CoreStore

public final class Repository: RepositoryProtocol {
	
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
	
	public func getBookoutReasons() -> Effect<SuccessState<[BookoutReason]>, RequestError> {
        let countDB = self.coreDataModel.fetchCount(BookoutReasonScheme.self)
        
        if countDB == 0 {
            return self.clientAPI.getBookoutReasons()
                .map {
                    let state = SuccessState(state: $0, isFromDB: false)
                    state.state.forEach { $0.save(to: self.coreDataModel)}
                    log("Saved to DB")
                    return state
                }
        }
        
        return self.coreDataModel.fetchAllSchemes(BookoutReasonScheme.self)
            .map(BookoutReason.convert(from:))
            .map { SuccessState(state: $0, isFromDB: true) }
	}

	public func getLocations() -> Effect<SuccessState<[Location]>, RequestError> {
		let countDB = self.coreDataModel.fetchCount(LocationScheme.self)
        
        if countDB == 0 {
            return self.journeyAPI.getLocations()
                .map {
                    let state = SuccessState(state: $0, isFromDB: false)
                    state.state.forEach { $0.save(to: self.coreDataModel)}
                    log("Saved to DB")
                    return state
                }
        }
        
        return self.coreDataModel.fetchAllSchemes(LocationScheme.self)
            .map(Location.convert(from:))
            .map { SuccessState(state: $0, isFromDB: true) }
	}
    
    public func getEmployees() -> Effect<SuccessState<[Employee]>, RequestError> {
        let countDB = self.coreDataModel.fetchCount(EmployeeScheme.self)
        
        if countDB == 0 {
            return self.journeyAPI.getEmployees()
                .map {
                    let state = SuccessState(state: $0, isFromDB: false)
                    state.state.forEach { $0.save(to: self.coreDataModel)}
                    log("Saved to DB")
                    return state
                }
        }
        
        return self.coreDataModel.fetchAllSchemes(EmployeeScheme.self)
            .map(Employee.convert(from:))
            .map { SuccessState(state: $0, isFromDB: true) }
    }
    
    public func getTemplates(_ type: FormType) -> Effect<SuccessState<[FormTemplateInfo]>, RequestError> {
        let countDB = try? self.coreDataModel.dataStack.fetchCount(
            From(FormTemplateInfoScheme.self),
            Where<FormTemplateInfoScheme>("%K > %d", "type", type.rawValue)
        )
        
        if countDB == 0 {
            return self.formAPI.getTemplates(type)
                .map {
                    let state = SuccessState(state: $0, isFromDB: false)
                    state.state.forEach { $0.save(to: self.coreDataModel)}
                    log("Saved to DB")
                    return state
                }
        }
  
        return self.coreDataModel.fetchAllSchemes(FormTemplateInfoScheme.self)
            .map(FormTemplateInfo.convert(from:))
            .map { SuccessState(state: $0.filter {$0.type == type}, isFromDB: true) }
    }

    public func getPathwayTemplates() -> Effect<SuccessState<IdentifiedArrayOf<PathwayTemplate>>, RequestError> {
        let countDB = self.coreDataModel.fetchCount(PathwayTemplateScheme.self)
        
        if countDB == 0 {
            return self.journeyAPI.getPathwayTemplates()
                .map {
                    let state = SuccessState(state: IdentifiedArrayOf.init($0), isFromDB: false)
                    state.state.forEach { $0.save(to: self.coreDataModel)}
                    log("Saved to DB")
                    
                    return  state
                }
        }
     
        return self.coreDataModel.fetchAllSchemes(PathwayTemplateScheme.self)
            .map(PathwayTemplate.convert(from:))
            .map { SuccessState(state: IdentifiedArrayOf.init($0), isFromDB: true) }
    }
}

