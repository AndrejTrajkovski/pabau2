import Model
import CoreDataModel
import ChooseEmployees

public typealias AddShiftEnvironment = (apiClient: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeChooseEmployeesEnv(_ addShiftEnv: AddShiftEnvironment) -> ChooseEmployeesEnvironment {
	return ChooseEmployeesEnvironment(
		journeyAPI: addShiftEnv.apiClient,
		repository: addShiftEnv.repository
	)
}
