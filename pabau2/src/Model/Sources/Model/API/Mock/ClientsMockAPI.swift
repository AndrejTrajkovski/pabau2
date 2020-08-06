import ComposableArchitecture
import SwiftDate

public struct ClientsMockAPI: MockAPI, ClientsAPI {
	public func getClients() -> Effect<Result<[Client], RequestError>, Never> {
		mockSuccess(Self.mockClients, delay: 0.2)
	}
	
	public func getItemsCount(clientId: Int) -> Effect<Result<ClientItemsCount, RequestError>, Never> {
		mockSuccess(ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
	}
	
	public func getAppointments(clientId: Int) -> Effect<Result<[Appointment], RequestError>, Never> {
		mockSuccess(Self.mockAppointments, delay: 2.0)
	}
	public func getPhotos(clientId: Int) -> Effect<Result<[SavedPhoto], RequestError>, Never> {
		mockSuccess([])
	}
	public func getFinancials(clientId: Int) -> Effect<Result<[Financial], RequestError>, Never> {
		mockSuccess([])
	}
	public func getForms(type: FormType, clientId: Int) -> Effect<Result<[FormData], RequestError>, Never> {
		mockSuccess([])
	}
	public func getDocuments(clientId: Int) -> Effect<Result<[Document], RequestError>, Never> {
		mockSuccess(Self.mockDocs, delay: 0.2)
	}
	public func getCommunications(clientId: Int) -> Effect<Result<[Communication], RequestError>, Never> {
		mockSuccess([])
	}
	public func getAlerts(clientId: Int) -> Effect<Result<[Alert], RequestError>, Never> {
		mockSuccess([])
	}
	
	public func getNotes(clientId: Int) -> Effect<Result<[Note], RequestError>, Never> {
		mockSuccess([])
	}
	
	public init () {}
}

extension ClientsMockAPI {
	
	static let mockFilledConsents =
		[
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[3],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
	]
	
	static let mockFilledTreatments =
		[
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[3],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
	]
	
	static let mockClients =
		[
			Client(id:1, firstName: "Jessica", lastName:"Avery", dOB: Date(), email: "ninenine@me.com", avatar: "dummy1"),
			Client(id:2, firstName: "Joan", lastName:"Bailey", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:3, firstName: "Joanne", lastName:"Baker", dOB: Date(), email: "redingtn@yahoo.ca", avatar: nil),
			Client(id:4, firstName: "Julia", lastName:"Ball", dOB: Date(), email: "bolow@mac.com", avatar: "dummy2"),
			Client(id:5, firstName: "Karen", lastName:"Bell", dOB: Date(), email: "microfab@msn.com", avatar: nil),
			Client(id:6, firstName: "Katherine", lastName:"Berry", dOB: Date(), avatar: nil),
			Client(id:7, firstName: "Kimberly", lastName:"Black", dOB: Date(), email: "msloan@msn.com", avatar: nil),
			Client(id:8, firstName: "Kylie", lastName:"Blake", dOB: Date(), email: "seano@yahoo.com", avatar: "dummy3"),
			Client(id:9, firstName: "Lauren", lastName:"Bond", dOB: Date(), email: "jorgb@aol.com", avatar: "dummy4"),
			Client(id:10, firstName: "Leah", lastName:"Bower", dOB: Date(), avatar: "dummy5"),
			Client(id:11, firstName: "Lillian", lastName:"Brown", dOB: Date(), email: "nogin@gmail.com", avatar: "dummy6"),
			Client(id:12, firstName: "Lily", lastName:"Buckland", dOB: Date(), email: "redingtn@hotmail.com", avatar: "dummy7"),
			Client(id:13, firstName: "Lisa", lastName:"Burgess", dOB: Date(), avatar: nil),
			Client(id:14, firstName: "Madeleine", lastName:"Butler", dOB: Date(), avatar: nil),
			Client(id:15, firstName: "Maria", lastName:"Cameron", dOB: Date(), email: "gilmoure@verizon.net", avatar: nil),
			Client(id:16, firstName: "Mary", lastName:"Campbell", dOB: Date(), avatar: nil),
			Client(id:17, firstName: "Megan", lastName:"Carr", dOB: Date(), avatar: "dummy8"),
			Client(id:18, firstName: "Melanie", lastName:"Chapman", dOB: Date(), email: "dpitts@att.net", avatar: "dummy9"),
			Client(id:19, firstName: "Michelle", lastName:"Churchill", dOB: Date(), avatar: nil),
			Client(id:20, firstName: "Molly", lastName:"Clark", dOB: Date(), avatar: nil),
			Client(id:21, firstName: "Natalie", lastName:"Clarkson", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:22, firstName: "Nicola", lastName:"Avery", dOB: Date(), avatar: nil),
			Client(id:23, firstName: "Olivia", lastName:"Bailey", dOB: Date(), avatar: nil),
			Client(id:24, firstName: "Penelope", lastName:"Baker", dOB: Date(), avatar: "dummy10"),
			Client(id:25, firstName: "Pippa", lastName:"Ball", dOB: Date(), avatar: nil),
	]
	
	static let mockAppointments =
		[
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "London", service: BaseService.init(id: 1, name: "Botox", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "RU", locationId: 1, locationName: "Skopje", service: BaseService.init(id: 1, name: "Fillers", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "London", service: BaseService.init(id: 1, name: "Wax Job", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "Thailand", service: BaseService.init(id: 1, name: "Haircut", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "Manchester", service: BaseService.init(id: 1, name: "Thai Massage", color: "#eb4034"))
	]
	
	
	static let mockDocs =
		[
			Document(id: 1, title: "Ticket", format: .txt, date: Date()),
			Document(id: 3, title: "Some bmp file", format: .bmp, date: Date()),
			Document(id: 4, title: "Excel List", format: .csv, date: Date()),
			Document(id: 5, title: "Medical History", format: .doc, date: Date()),
			Document(id: 6, title: "Homework", format: .docx, date: Date()),
			Document(id: 7, title: "Drivers License", format: .jpg, date: Date()),
			Document(id: 8, title: "List", format: .numbers, date: Date()),
			Document(id: 9, title: "Blah Blah", format: .pages, date: Date()),
			Document(id: 10, title: "CV", format: .pdf, date: Date()),
			Document(id: 11, title: "Client Passport", format: .png, date: Date()),
			Document(id: 12, title: "Tif file", format: .tif, date: Date()),
			Document(id: 13, title: "Notes", format: .txt, date: Date()),
			Document(id: 14, title: "XLS", format: .xls, date: Date()),
			Document(id: 15, title: "XLSX", format: .xlsx, date: Date())
	]
}
