import Model
import Overture
import Tagged
import SwiftDate

enum IntervalsAdapter {
//	func day(_ calendar: CalendarResponse,
//					 _ minutesInterval: Int) -> CalendarCells {
//		let eids: [Employee.Id] = Array(calendar.rota.keys)
//		return eids.map { (employeeId: Employee.Id) in
//			return singleEmployeeCells(employeeId,
//																 calendar.rota[employeeId],
//																 calendar.appointments.filter(with(employeeId, curry(isBy(id:appointment:)))),
//																 minutesInterval)
//		}
//	}
	
	func isBy(id: Employee.Id, appointment: CalAppointment) -> Bool {
		appointment.employeeId == id
	}
	
	func singleEmployeeCells(_ id: Employee.Id,
													 _ shifts: [Shift]?,
													 _ appointments: [CalAppointment],
													 _ minutesInterval: Int) -> [IntervalInfo] {
		fatalError()
	}
	
	static func makeList(appointments: [CalAppointment]) -> AdjacencyList<CalAppointment> {
		let list = AdjacencyList<CalAppointment>()
		appointments.forEach {
			list.createVertex(data: $0)
		}
//		list.adjacencyDict.forEach { vertex in
//			list.add(.undirected,
//							 from: vertex,
//							 to: <#T##Vertex<AdjacencyList<Appointment>.Element>#>, weight: <#T##Double?#>)
//		}
		for idx in 0..<appointments.count {
			let app = appointments[idx]
			for idx2 in 0..<appointments.count where idx != idx2 {
				let otherApp = appointments[idx2]
				if app.intersectsWith(otherApp: otherApp) {
					list.add(.directed,
									 from: Vertex.init(data: app),
									 to: Vertex.init(data: otherApp),
									 weight: nil)
				}
			}
		}
		return list
	}
}

extension CalAppointment {
	func intersectsWith(otherApp: CalAppointment) -> Bool {
		self.start_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
		self.end_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
		otherApp.start_time.isInRange(date: self.start_time, and: self.end_time) ||
		otherApp.end_time.isInRange(date: self.start_time, and: self.end_time)
	}
}
