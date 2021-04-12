import Model
import Form

public typealias JourneyEnvironment = (
	formAPI: FormAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

func makeFormEnv(_ journeyEnv: JourneyEnvironment) -> FormEnvironment {
	return FormEnvironment(formAPI: journeyEnv.formAPI,
						   userDefaults: journeyEnv.userDefaults)
}
