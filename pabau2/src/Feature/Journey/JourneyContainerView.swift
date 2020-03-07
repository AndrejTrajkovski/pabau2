import SwiftUI
import FSCalendarSwiftUI
import Model
import Util

public struct JourneyContainerView: View {
	let calendarViewModel = MyCalendarViewModel()
	public init () {}
	public var body: some View {
		VStack {
			SwiftUICalendar.init(calendarViewModel)
			JourneyList(journeys: [Journey]())
		}
	}
	
	//	let appt1 = Journey(id: 0,
	//											appointments: [],
	//											patient: BaseClient(),
	//											employee: Employee())
	//
	//	let journeys: [Journey] = [
	//
	//	]
}

func journeyCellAdapter(journey: Journey) -> JourneyCell {
	return JourneyCell(
		color: Color.init(hex: journey.appointments.first!.service!.color),
		time: "12:30",
		imageUrl: journey.patient.avatar,
		name: journey.patient.firstName + journey.patient.lastName,
		services: journey.appointments
			.map{ $0.service }
			.compactMap { $0?.name }
			.reduce("", +),
		status: journey.appointments.first?.status?.name,
		employee: journey.employee.name,
		paidStatus: "Paid",
		stepsComplete: 0,
		stepsTotal: 3)
}

struct JourneyList: View {
	let journeys: [Journey]
	var body: some View {
		List {
			ForEach(journeys) { journey in
				journeyCellAdapter(journey: journey)
			}
		}
	}
}

struct JourneyCell: View {
	let color: Color
	let time: String
	let imageUrl: String?
	let name: String
	let services: String
	let status: String?
	let employee: String
	let paidStatus: String
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		HStack {
			JourneyColorRect(color: color)
			Text(time)
			Image(imageUrl ?? "avatar_placeholder")
			VStack {
				Text(name)
				Text(services)
				Text(status ?? "")
			}
			Image(systemName: "person")
			Text(employee)
			Image(systemName: "briefcase")
			Text(paidStatus)
			StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
		}
	}
}

struct StepsStatusView: View {
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		Ellipse()
			.fill(Color.blue)
			.frame(width: 100.0, height: 50.0)
	}
}

struct JourneyColorRect: View {
	let color: Color
	var body: some View {
		Rectangle()
			.frame(width: 8.0)
			.background(color)
	}
}
