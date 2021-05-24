import Model
import Util
import Foundation
import SharedComponents
import ComposableArchitecture
import ChooseEmployees
import ChooseLocation

public struct AddAppointmentState: Equatable {
	let editingAppointment: Appointment?
	var reminder: Bool
	var email: Bool
	var sms: Bool
	var feedback: Bool
	var isAllDay: Bool
	var startDate: Date
	var note: String = ""

	var durations: SingleChoiceLinkState<Duration>
	var participants: ChooseParticipantState
	var chooseLocationState: ChooseLocationState
	var with: ChooseEmployeesState
	var services: ChooseServiceState
	var clients: ChooseClientsState

	var employeeConfigurator = ViewConfigurator(errorString: "Employee is required")
	var chooseClintConfigurator = ViewConfigurator(errorString: "Client is required")
	var chooseDateConfigurator = ViewConfigurator(errorString: "Day is required")
	var chooseServiceConfigurator = ViewConfigurator(errorString: "Service is required")

	var showsLoadingSpinner: Bool
	var alertBody: AlertBody?

	var appointmentsBody: AppointmentBuilder {
		if let editingAppointment = editingAppointment {
			return AppointmentBuilder(appointment: editingAppointment)
		}

		return AppointmentBuilder(
			isAllDay: self.isAllDay,
			clientID: self.clients.chosenClient?.id,
			locationID: self.chooseLocationState.chosenLocation?.id,
			employeeID: self.with.chosenEmployeeId?.rawValue,
			serviceID: self.services.chosenService?.id.rawValue,
			startTime: self.startDate,
			duration: self.durations.dataSource.first(where: {$0.id == self.durations.chosenItemId})?.duration,
			smsNotification: self.sms,
			emailNotification: self.email,
			surveyNotification: self.feedback,
			reminderNotification: self.reminder,
			note: self.note,
			participantUserIDS: self.participants.chosenParticipants.compactMap { $0.id.rawValue }
		)
	}
}

extension Employee: SingleChoiceElement { }
extension Service: SingleChoiceElement { }

extension Client: SingleChoiceElement {
	public var name: String {
		return firstName + " " + lastName
	}
}

extension AddAppointmentState {

	public init(
		editingAppointment: Appointment? = nil,
		startDate: Date,
		endDate: Date
	) {
		self.init(
			editingAppointment: nil,
			reminder: false,
			email: false,
			sms: false,
			feedback: false,
			isAllDay: false,
			startDate: startDate,
			durations: AddAppMocks.durationState,
			participants: ChooseParticipantState(isChooseParticipantActive: false),
			chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
			with: ChooseEmployeesState(chosenEmployeeId: nil,
									   employees: []),
			services: ChooseServiceState(
				isChooseServiceActive: false,
				filterChosen: .allStaff
			),
			clients: ChooseClientsState(
				isChooseClientsActive: false,
				chosenClient: nil
			),
			showsLoadingSpinner: false
		)
	}

	public init(
		startDate: Date,
		endDate: Date,
		employee: Employee
	) {
		self.init(
			editingAppointment: nil,
			reminder: false,
			email: false,
			sms: false,
			feedback: false,
			isAllDay: false,
			startDate: startDate,
			durations: AddAppMocks.durationState,
			participants: ChooseParticipantState(isChooseParticipantActive: false),
			chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
			with: ChooseEmployeesState(chosenEmployeeId: employee.id,
									   employees: []),
			services: ChooseServiceState(
				isChooseServiceActive: false,
				filterChosen: .allStaff
			),
			clients: ChooseClientsState(
				isChooseClientsActive: false,
				chosenClient: nil
			),
			showsLoadingSpinner: false
		)
	}
}

struct AddAppMocks {

	static let serviceState: SingleChoiceLinkState<Service> =
		SingleChoiceLinkState.init(
			dataSource: [
				Service.init(id: "1", name: "Botox", color: "", categoryName: "Injectables"),
				Service.init(id: "2", name: "Fillers", color: "", categoryName: "Urethra"),
				Service.init(id: "3", name: "Facial", color: "", categoryName: "Mosaic")
			],
			chosenItemId: "1",
			isActive: false)

	static let durationState: SingleChoiceLinkState<Duration> =
		SingleChoiceLinkState.init(
			dataSource: IdentifiedArray(Duration.all),
			chosenItemId: 1,
			isActive: false)

	static let withState: SingleChoiceLinkState<Employee> =
		SingleChoiceLinkState.init(
			dataSource: [

			],
			chosenItemId: "456",
			isActive: false)

	static let participantsState: SingleChoiceLinkState<Employee> =
		SingleChoiceLinkState.init(
			dataSource: [
			],
			chosenItemId: "1",
			isActive: false)
}

extension AddAppointmentState {
	public static let dummy = AddAppointmentState.init(
		editingAppointment: nil,
		reminder: false,
		email: false,
		sms: false,
		feedback: false,
		isAllDay: false,
		startDate: Date(),
		durations: AddAppMocks.durationState,
		participants: ChooseParticipantState(isChooseParticipantActive: false),
		chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
		with: ChooseEmployeesState(chosenEmployeeId: nil,
								   employees: []),
		services: ChooseServiceState(
			isChooseServiceActive: false,
			filterChosen: .allStaff
		),
		clients: ChooseClientsState(
			isChooseClientsActive: false,
			chosenClient: nil
		),
		showsLoadingSpinner: false
	)
}
