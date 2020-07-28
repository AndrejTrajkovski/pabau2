public protocol LiveAPI {
	var basePath: String { get }
	var route: String { get }
	var requestBuilderFactory: RequestBuilderFactory { get }
}
