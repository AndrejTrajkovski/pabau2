import Model
import Util
import ChooseLocationAndEmployee
import SharedComponents
import Foundation
import ComposableArchitecture

public struct AddBookoutState: Equatable {
	var editingBookout: Bookout?
	var chooseDuration: SingleChoiceState<Duration>
	var chooseLocAndEmp: ChooseLocationAndEmployeeState
	var chooseBookoutReasonState: ChooseBookoutReasonState
	var startDate: Date
	var time: Date?
	var description: String = ""
	var note: String = ""
	var isPrivate: Bool = false
	var isAllDay: Bool = false

	var showsLoadingSpinner: Bool = false

	var employeeValidator: String? = nil
	var dayValidator: String? = nil
	var timeValidator: String? = nil
	var durationValidator: String? = nil

	var appointmentsBody: AppointmentBuilder {
		return AppointmentBuilder(
			isAllDay: self.isAllDay,
			isPrivate: self.isPrivate,
			locationID: self.chooseLocAndEmp.chosenLocationId,
			employeeID: self.chooseLocAndEmp.chosenEmployeeId?.rawValue,
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
		chooseLocAndEmp: ChooseLocationAndEmployeeState,
		start: Date
	) {
		self.init(
			chooseDuration:
				SingleChoiceState<Duration>(
					dataSource: IdentifiedArray.init(Duration.all),
					chosenItemId: nil
				),
			chooseLocAndEmp: chooseLocAndEmp,
			chooseBookoutReasonState: ChooseBookoutReasonState(isChooseBookoutReasonActive: false),
			startDate: start,
			time: nil,
			description: "",
			note: "",
			isPrivate: false
		)
	}
	public init(
		chooseLocAndEmp: ChooseLocationAndEmployeeState,
		start: Date,
		bookout: Bookout
	) {
		self.init(
			chooseDuration:
				SingleChoiceState<Duration>(
					dataSource: IdentifiedArray.init(Duration.all),
					chosenItemId: nil
				),
			chooseLocAndEmp: chooseLocAndEmp,
			chooseBookoutReasonState: ChooseBookoutReasonState(isChooseBookoutReasonActive: false),
			startDate: bookout.start_date,
			time: nil,
			description: bookout._description ?? "",
			note: "",
			isPrivate: bookout._private ?? false
		)
	}
}