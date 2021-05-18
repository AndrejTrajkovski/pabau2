import Model
import Foundation

func calendarAPIParams(state: CalendarState) -> (
	startDate: Date,
	endDate: Date,
	locationIds: Set<Location.ID>,
	employeesIds: [Employee.ID]?,
	roomIds: [Room.ID]?) {
	let startDate: Date
	let endDate: Date
	let employeesIds: [Employee.Id]?
	let roomIds: [Room.ID]?
	switch state.appointments.calendarType {
	case .employee, .list:
		startDate = state.selectedDate
		endDate = state.selectedDate
		employeesIds = state.selectedEmployeesIds()
		roomIds = nil
	case .week:
		let week = state.selectedDate.datesInWeekOf()
		startDate = week.first!
		endDate = week.last!
		employeesIds = state.selectedEmployeesIds()
		roomIds = nil
	case .room:
		startDate = state.selectedDate
		endDate = state.selectedDate
		employeesIds = nil
		roomIds = state.selectedRoomsIds()
	}
	return (startDate: startDate, endDate: endDate, locationIds: state.chosenLocationsIds, employeesIds: employeesIds, roomIds: roomIds)
}
