import ComposableArchitecture

public protocol ClientsAPI {
	func getClients() -> Effect<Result<[Client], RequestError>, Never>
}
