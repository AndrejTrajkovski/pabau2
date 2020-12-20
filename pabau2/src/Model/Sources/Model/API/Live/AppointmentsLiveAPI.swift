import ComposableArchitecture

public struct AppointmentsLiveAPI: AppointmentsAPI, LiveAPI {
	public func getEmployees() -> Effect<Result<[Employee], RequestError>, Never> {
		fatalError()
	}

	public func getAppointments(date: Date) -> Effect<Result<[Appointment], RequestError>, Never> {
		getAppointments(date: date).effect()
	}

	public let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	public var basePath: String = ""
	public let route: String = "appointments"

	private func getAppointments(date: Date) -> RequestBuilder<[Appointment]> {
		let URLString = basePath + route + "journeys"
		let parameters: [String: Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"date": try? newJSONEncoder().encode(date)
		])

		let requestBuilder: RequestBuilder<[Appointment]>.Type = requestBuilderFactory.getBuilder()

		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
}
