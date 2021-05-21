import Filters
import Model
import CoreDataModel

public typealias CalendarEnvironment = (journeyAPI: JourneyAPI, clientsAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

func makeFiltersEnv(calendarEnv: CalendarEnvironment) -> FiltersEnvironment {
	return FiltersEnvironment(
		journeyAPI: calendarEnv.journeyAPI,
		userDefaults: calendarEnv.userDefaults,
		repository: calendarEnv.repository
	)
}
