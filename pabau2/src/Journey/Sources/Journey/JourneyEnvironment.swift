import Model
import Form
import CoreDataModel

public typealias JourneyEnvironment = (
	formAPI: FormAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig,
    repository: Repository,
	audioPlayer: AudioPlayerProtocol
)

func makeFormEnv(_ journeyEnv: JourneyEnvironment) -> FormEnvironment {
    FormEnvironment(
        formAPI: journeyEnv.formAPI,
        userDefaults: journeyEnv.userDefaults,
        repository: journeyEnv.repository
    )
}
