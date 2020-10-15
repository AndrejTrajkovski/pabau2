import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class CalendarViewController: BaseCalendarViewController {

	public override func setupCalendarView() -> CalendarView {
		let calendarView = super.setupCalendarView()
		calendarView.sectionLongPressDelegate = self
		return calendarView
	}
}

// MARK: - SectionLongPressDelegate
extension CalendarViewController: SectionLongPressDelegate {
	
	fileprivate func maybeUpdateDateWith(_ endPageAndSectionIdx: (Int?, Int?), _ calEvent: inout CalAppointment) {
		let (pageIdxOpt, withinSectionIdxOpt) = endPageAndSectionIdx
		if let pageIdx = pageIdxOpt,
		   let withinSectionIdx = withinSectionIdxOpt,
		   let firstSectionApp = calendarView.getFirstEvent(pageIdx, withinSectionIdx) as? AppointmentEvent
		{
			update(&calEvent,
				   viewStore.state.calendarType,
				   firstSectionApp.app)
		}
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (Int?, Int?), startPageAndSectionIdx: (Int?, Int?)) {
		if let appointmentEvent = editingEvent as? AppointmentEvent {
			//TODO: Move this logic to reducer
			var calEvent = appointmentEvent.app
			if calEvent.start_date.startOfDay == startDate.startOfDay {
				maybeUpdateDateWith(endPageAndSectionIdx, &calEvent)
			}
			updateTimeOn(&calEvent, startDate)
			viewStore.send(.replaceAppointment(newApp: AppointmentEvent(appointment: calEvent),
											   id: calEvent.id))
		}
	}

	public func weekView(_ weekView: JZLongPressWeekView,
						 didEndAddNewLongPressAt
							startDate: Date,
						 pageAndSectionIdx: (Int?, Int?)) {
		//TODO: Move this logic to reducer
		let endDate = Calendar.current.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
		var newApp = CalAppointment.dummyInit(start: startDate, end: endDate)
		maybeUpdateDateWith(pageAndSectionIdx, &newApp)
		viewStore.send(.addAppointment(AppointmentEvent(appointment: newApp)))
	}
}

extension CalendarViewController {

	func keyPath(calType: CalendarType) -> AnyHashableKeyPath<CalAppointment> {
		switch calType {
		case .day:
			let kpe = \CalAppointment.employeeId
			return AnyHashableKeyPath(kpe)
		case .room:
			let kps = \CalAppointment.roomId
			return AnyHashableKeyPath(kps)
		default: fatalError()
		}
	}

	private func update(_ appointment: inout CalAppointment,
						_ fromApp: CalAppointment,
						_ keyPath: AnyHashableKeyPath<CalAppointment>) {
		keyPath.set(&appointment, keyPath.get(fromApp))
	}
	
	private func update(_ appointment: inout CalAppointment,
						_ calType: CalendarType,
						_ fromApp: CalAppointment) {
		update(&appointment,
			   fromApp,
			   keyPath(calType: calType))
	}
}
