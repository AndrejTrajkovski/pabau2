import ComposableArchitecture

public protocol ClientsAPI {
	func getClients() -> Effect<Result<[Client], RequestError>, Never>
	func getItemsCount(clientId: Int) -> Effect<Result<ClientItemsCount, RequestError>, Never>
}
