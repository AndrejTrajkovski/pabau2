import Model
import Foundation
import NonEmpty
import CasePaths
import Overture
import Appointments

public typealias Journey = [Appointment]

extension Journey: Identifiable {
	public var id: JourneyKey {
		JourneyKey(customerId: self.first!.customerId,
				   employeeId: self.first!.employeeId)
	}
}

public extension Journey {
	var servicesString: String {
		self.compactMap { $0.service }
			.reduce("", +)
	}
}

let filterAppointments = with(CalendarEvent.appointment, curry(extract(case:from:)))

func calendarResponseToJourneys(date: Date, events: [CalendarEvent]) -> [Journey] {
	return with(events.compactMap(filterAppointments),
				with(date, curry(groupAndFilter(date:appointments:))))
}

func groupAndFilter(date: Date, appointments: [Appointment]) -> [Journey] {
	journeyGroup(appointments: appointments)
		.first { $0.key.isInside(date: date.cutToDay(), granularity: .day) }
		.map(\.value) ?? []
}

public struct JourneyKey: Hashable {
	let customerId: Client.ID
	let employeeId: Employee.ID
}

func journeyGroup(appointments: [Appointment]) -> [Date: [Journey]] {
	return Dictionary(grouping: appointments, by: { $0.start_date.cutToDay() })
		.mapValues {
			Dictionary(grouping: $0, by: {
				return JourneyKey(customerId: $0.customerId, employeeId: $0.employeeId)
			}).map(\.value)
			.sorted(by: \.first!.start_date)
		}
}
