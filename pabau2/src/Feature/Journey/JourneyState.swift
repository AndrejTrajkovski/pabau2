import Model
import Util
import NonEmpty
import SwiftDate

public struct JourneyState: Equatable {
	public init () {}
	public var loadingState: LoadingState = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""

	var selectedJourney: Journey?
	var isChoosePathwayShown: Bool = false
	var isChooseConsentShown: Bool = false
	var selectedTemplatesIds: [Int] = [1, 2, 3]
	var templates: [FormTemplate] = [
		FormTemplate(id: 1, name: "Consent - Hair Extension", formType: .consent),
		FormTemplate(id: 2, name: "Consent - Botox", formType: .consent),
		FormTemplate(id: 3, name: "Consent - Fillers", formType: .consent),
		FormTemplate(id: 4, name: "Consent - Pedicure", formType: .consent),
		FormTemplate(id: 5, name: "Consent - Manicure", formType: .consent),
		FormTemplate(id: 6, name: "Consent - Skin Treatment", formType: .consent),
		FormTemplate(id: 7, name: "Consent - Lipo", formType: .consent)
	]
	var isModalShown: Bool = false
	var choosePathway: ChoosePathwayState {
		get {
			return ChoosePathwayState(journey: self.selectedJourney,
																isChooseConsentShown: self.isChooseConsentShown,
																selectedTemplatesIds: self.selectedTemplatesIds,
																templates: self.templates)
		}
		set {
			self.selectedJourney = newValue.journey
			self.isChooseConsentShown = newValue.isChooseConsentShown
			self.selectedTemplatesIds = newValue.selectedTemplatesIds
			self.templates = newValue.templates
		}
	}
	public var employeesState: EmployeesState = EmployeesState()
	
	var addAppointment: AddAppointmentState = AddAppointmentState.init(
		isShowingAddAppointment: false,
		reminder: false,
		email: false,
		sms: false,
		feedback: false,
		isAllDay: false,
		clients: JourneyMocks.clientState,
		termins: JourneyMocks.terminState,
		services: JourneyMocks.serviceState,
		durations: JourneyMocks.durationState,
		with: JourneyMocks.withState,
		participants: JourneyMocks.participantsState)
	
	var filteredJourneys: [Journey] {
		return self.journeys
			.filter { $0.appointments.first.from.isInside(date: selectedDate, granularity: .day) }
			.filter { employeesState.selectedEmployeesIds.contains($0.employee.id) }
			.sorted(by: { $0.appointments.first.from > $1.appointments.first.from })
	}
}

//MOCKS
struct JourneyMocks {
	static let clientState: PickerContainerState<Client> =
		PickerContainerState.init(
			dataSource: [
				Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
				Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
			],
			chosenItemId: 1,
			isActive: false)
	
	static let terminState: PickerContainerState<MyTermin> = PickerContainerState.init(
		dataSource: [
			MyTermin.init(name: "12:30", id: 1, date: Date()),
			MyTermin.init(name: "13:30", id: 2, date: Date()),
			MyTermin.init(name: "14:30", id: 3, date: Date())
		],
		chosenItemId: 1,
		isActive: false)
	
	static let serviceState: PickerContainerState<Service> =
		PickerContainerState.init(
			dataSource: [
				Service.init(id: 1, name: "Botox", color: ""),
				Service.init(id: 2, name: "Fillers", color: ""),
				Service.init(id: 3, name: "Facial", color: "")
			],
			chosenItemId: 1,
			isActive: false)
	
	static let durationState: PickerContainerState<Duration> =
		PickerContainerState.init(
			dataSource: [
				Duration.init(name: "00:30", id: 1, duration: 30),
				Duration.init(name: "01:00", id: 2, duration: 60),
				Duration.init(name: "01:30", id: 3, duration: 90)
			],
			chosenItemId: 1,
			isActive: false)
	
	static let withState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Andrej Trajkovski"),
				Employee.init(id: 2, name: "Mark Ronson")
			],
			chosenItemId: 1,
			isActive: false)
	
	static let participantsState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Participant 1"),
				Employee.init(id: 2, name: "Participant 2")
			],
			chosenItemId: 1,
			isActive: false)
}
