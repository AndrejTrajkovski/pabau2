import Model
import CoreDataModel
import ChooseLocationAndEmployee

public typealias AddAppointmentEnv = (journeyAPI: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeChooseLocAndEmpEnv(_ addAppEnv: AddAppointmentEnv) -> ChooseLocationAndEmployeeEnv {
	return ChooseLocationAndEmployeeEnv(
		journeyAPI: addAppEnv.journeyAPI,
		repository: addAppEnv.repository
	)
}
