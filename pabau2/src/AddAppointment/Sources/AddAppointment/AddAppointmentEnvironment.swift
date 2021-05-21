import Model
import CoreDataModel
import ChooseLocation
import ChooseEmployees

public typealias AddAppointmentEnv = (journeyAPI: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeChooseLocationEnv(_ addAppEnv: AddAppointmentEnv) -> ChooseLocationEnvironment {
	return ChooseLocationEnvironment(
		repository: addAppEnv.repository,
		userDefaults: addAppEnv.userDefaults
	)
}

func makeChooseEmployeesEnv(_ addAppEnv: AddAppointmentEnv) -> ChooseEmployeesEnvironment {
	return ChooseEmployeesEnvironment(
		journeyAPI: addAppEnv.journeyAPI,
		repository: addAppEnv.repository
	)
}
