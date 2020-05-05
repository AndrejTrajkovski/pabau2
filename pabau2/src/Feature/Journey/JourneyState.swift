import Model
import Util
import NonEmpty
import SwiftDate

public struct JourneyState: Equatable {
	public init () {
		print("init journey state")
	}
	public var loadingState: LoadingState = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	public var employeesState: EmployeesState = EmployeesState()
	public var selectedJourney: Journey?
	public var selectedPathway: Pathway?
	var selectedConsentsIds: [Int] = []
	var allConsents: [FormTemplate] = []
	public var checkIn: CheckInContainerState?
//		= JourneyMocks.checkIn

	public var addAppointment: AddAppointmentState = AddAppointmentState.init(
		isShowingAddAppointment: false,
		reminder: false,
		email: false,
		sms: false,
		feedback: false,
		isAllDay: false,
		clients: JourneyMocks.clientState,
		termins: JourneyMocks.terminState,
		services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
		durations: JourneyMocks.durationState,
		with: JourneyMocks.withState,
		participants: JourneyMocks.participantsState)
}

extension JourneyState {

	var choosePathway: ChoosePathwayState {
		get {
			ChoosePathwayState(selectedJourney: selectedJourney,
											selectedPathway: selectedPathway,
											selectedConsentsIds: selectedConsentsIds,
											allConsents: allConsents)
		}
		set {
			self.selectedJourney = newValue.selectedJourney
			self.selectedPathway = newValue.selectedPathway
			self.selectedConsentsIds = newValue.selectedConsentsIds
			self.allConsents = newValue.allConsents
		}
	}

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
				Service.init(id: 1, name: "Botox", color: "", categoryId: 1, categoryName: "Injectables"),
				Service.init(id: 2, name: "Fillers", color: "", categoryId: 2, categoryName: "Urethra"),
				Service.init(id: 3, name: "Facial", color: "", categoryId: 3, categoryName: "Mosaic")
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
	
	static let checkIn = CheckInContainerState(
		journey:
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		pathway:
		Pathway.init(id: 1,
								 title: "Standard",
								 steps: [Step(id: 1, stepType: .checkpatient),
												 Step(id: 2, stepType: .medicalhistory),
												 Step(id: 3, stepType: .consents),
												 Step(id: 4, stepType: .treatmentnotes),
												 Step(id: 5, stepType: .prescriptions),
												 Step(id: 6, stepType: .aftercares)
		]),
		patientDetails: PatientDetails(),
		medHistory: JourneyMockAPI.getMedHistory(),
		consents: JourneyMockAPI.mockConsents)
}
