import Model
import CoreDataModel
import ChooseEmployees
import ChooseLocation

public typealias AddBookoutEnvironment = (journeyAPI: JourneyAPI, repository: Repository, userDefaults: UserDefaultsConfig)

func makeChooseEmployeesEnv(_ addBookoutEnv: AddBookoutEnvironment) -> ChooseEmployeesEnvironment {
	return ChooseEmployeesEnvironment(
		journeyAPI: addBookoutEnv.journeyAPI, repository: addBookoutEnv.repository
	)
}

func makeChooseLocationEnv(_ addBookoutEnv: AddBookoutEnvironment) -> ChooseLocationEnvironment {
	return ChooseLocationEnvironment(
		repository: addBookoutEnv.repository,
		userDefaults: addBookoutEnv.userDefaults
	)
}
