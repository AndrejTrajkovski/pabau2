import Model
import Util
import ChooseLocation
import ChooseEmployees
import SharedComponents
import Foundation
import ComposableArchitecture

public struct AddBookoutState: Equatable {
	var editingBookout: Bookout?
	var chooseEmployee: SingleChoiceLinkState<Employee>
	var chooseDuration: SingleChoiceState<Duration>
	var chooseLocationState: ChooseLocationState
	var chooseEmployeesState: ChooseEmployeesState
	var chooseBookoutReasonState: ChooseBookoutReasonState
	var startDate: Date
	var time: Date?
	var description: String = ""
	var note: String = ""
	var isPrivate: Bool = false
	var isAllDay: Bool = false

	var showsLoadingSpinner: Bool = false

	var employeeConfigurator = ViewConfigurator(errorString: "Employee is required")
	var dayConfigurator = ViewConfigurator(errorString: "Day is required")
	var timeConfigurator = ViewConfigurator(errorString: "Time is required")
	var durationConfigurator = ViewConfigurator(errorString: "Duration is required")

	var appointmentsBody: AppointmentBuilder {
		return AppointmentBuilder(
			isAllDay: self.isAllDay,
			isPrivate: self.isPrivate,
			locationID: self.chooseLocationState.chosenLocation?.id,
			employeeID: self.chooseEmployeesState.chosenEmployee?.id.rawValue,
			startTime: self.startDate,
			duration: self.chooseDuration.dataSource.first(where: {$0.id == self.chooseDuration.chosenItemId})?.duration,
			note: self.note,
			description: self.chooseBookoutReasonState.chosenReasons?.name
		)
	}
}

extension Employee: SingleChoiceElement {}

extension AddBookoutState {
	public init(
		employees: IdentifiedArrayOf<Employee>,
		chosenEmployee: Employee.ID?,
		start: Date
	) {
		self.init(
			chooseEmployee: SingleChoiceLinkState.init(
				dataSource: employees,
				chosenItemId: chosenEmployee,
				isActive: false
			),
			chooseDuration:
				SingleChoiceState<Duration>(
					dataSource: IdentifiedArray.init(Duration.all),
					chosenItemId: nil
				),
			chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
			chooseEmployeesState: ChooseEmployeesState(chosenEmployee: nil),
			chooseBookoutReasonState: ChooseBookoutReasonState(isChooseBookoutReasonActive: false),
			startDate: start,
			time: nil,
			description: "",
			note: "",
			isPrivate: false
		)
	}
	public init(
		employees: IdentifiedArrayOf<Employee>,
		chosenEmployee: Employee.ID?,
		start: Date,
		bookout: Bookout
	) {
		self.init(
			chooseEmployee: SingleChoiceLinkState.init(
				dataSource: employees,
				chosenItemId: chosenEmployee,
				isActive: false
			),
			chooseDuration:
				SingleChoiceState<Duration>(
					dataSource: IdentifiedArray.init(Duration.all),
					chosenItemId: nil
				),
			chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
			chooseEmployeesState: ChooseEmployeesState(chosenEmployee: nil),
			chooseBookoutReasonState: ChooseBookoutReasonState(isChooseBookoutReasonActive: false),
			startDate: bookout.start_date,
			time: nil,
			description: bookout._description ?? "",
			note: "",
			isPrivate: bookout._private ?? false
		)
	}
}
