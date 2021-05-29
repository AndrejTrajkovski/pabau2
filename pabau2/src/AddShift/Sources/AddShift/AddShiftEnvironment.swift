import Model
import CoreDataModel
import ChooseLocationAndEmployee

public typealias AddShiftEnvironment = (apiClient: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeChooseLocAndEmpEnv(_ addShiftEnv: AddShiftEnvironment) -> ChooseLocationAndEmployeeEnv {
	return ChooseLocationAndEmployeeEnv(
		journeyAPI: addShiftEnv.apiClient,
		repository: addShiftEnv.repository
	)
}
