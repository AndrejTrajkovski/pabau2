import Model
import Util
import Foundation
import SharedComponents
import ComposableArchitecture
import ChooseLocationAndEmployee
import ToastAlert

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
	var chooseLocAndEmp: ChooseLocationAndEmployeeState
	var services: ChooseServiceState
	var clients: ChooseClientsState

	var employeeValidator: String?
	var chooseClintValidator: String?
	var chooseDateValidator: String?
	var chooseServiceValidator: String?

	var showsLoadingSpinner: Bool
	var alertBody: AlertBody?

	var appointmentsBody: AppointmentBuilder {
		if let editingAppointment = editingAppointment {
			return AppointmentBuilder(appointment: editingAppointment)
		}

		return AppointmentBuilder(
			isAllDay: self.isAllDay,
			clientID: self.clients.chosenClient?.id,
			locationID: self.chooseLocAndEmp.chosenLocationId,
			employeeID: self.chooseLocAndEmp.chosenEmployeeId?.rawValue,
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
    
    var toast: ToastState<AddAppointmentAction>?
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
		endDate: Date,
		chooseLocAndEmp: ChooseLocationAndEmployeeState
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
			chooseLocAndEmp: chooseLocAndEmp,
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
		employee: Employee,
		chooseLocAndEmp: ChooseLocationAndEmployeeState
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
			chooseLocAndEmp: chooseLocAndEmp,
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

	static let durationState: SingleChoiceLinkState<Duration> =
		SingleChoiceLinkState.init(
			dataSource: IdentifiedArray(Duration.all),
			chosenItemId: nil,
			isActive: false,
			loadingState: .initial)
}

extension AddAppointmentState {
    public init(chooseLocAndEmp: ChooseLocationAndEmployeeState, startDate: Date? = nil) {
		self.init(
			editingAppointment: nil,
			reminder: false,
			email: false,
			sms: false,
			feedback: false,
			isAllDay: false,
			startDate: startDate ?? Date(),
			durations: AddAppMocks.durationState,
			participants: ChooseParticipantState(isChooseParticipantActive: false),
			chooseLocAndEmp: chooseLocAndEmp,
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
