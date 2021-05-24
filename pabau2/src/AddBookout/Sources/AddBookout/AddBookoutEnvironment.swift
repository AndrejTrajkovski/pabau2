import Model
import CoreDataModel
import ChooseLocationAndEmployee

public typealias AddBookoutEnvironment = (journeyAPI: JourneyAPI, repository: Repository, userDefaults: UserDefaultsConfig)

func makeChooseLocAndEmpEnv(_ addBookoutEnv: AddBookoutEnvironment) -> ChooseLocationAndEmployeeEnv {
	return ChooseLocationAndEmployeeEnv(
		journeyAPI: addBookoutEnv.journeyAPI,
		repository: addBookoutEnv.repository
	)
}
