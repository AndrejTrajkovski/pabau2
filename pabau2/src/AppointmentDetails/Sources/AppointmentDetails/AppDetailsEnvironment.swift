import Model
import CoreDataModel
import ChoosePathway

public typealias AppDetailsEnvironment = (journeyAPI: JourneyAPI, clientsAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeChoosePathwayEnv(_ appDetailsEnv: AppDetailsEnvironment) -> ChoosePathwayEnvironment {
	return ChoosePathwayEnvironment(
		journeyAPI: appDetailsEnv.journeyAPI,
		clientsAPI: appDetailsEnv.clientsAPI,
		userDefaults: appDetailsEnv.userDefaults,
		repository: appDetailsEnv.repository
	)
}
