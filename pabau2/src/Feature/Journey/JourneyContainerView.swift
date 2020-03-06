import SwiftUI
import FSCalendarSwiftUI
import Model

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

func color(hexString: String) -> Color {
	return Color.init
}

func journeyCell(journey: Journey) -> [JourneyCell] {
	return JourneyCell.init(
		color: Color.init(red: <#T##Double#>, green: <#T##Double#>, blue: <#T##Double#>), time: <#T##String#>, imageUrl: <#T##String#>, name: <#T##String#>, services: <#T##String#>, status: <#T##String#>, employee: <#T##String#>, paidStatus: <#T##String#>, stepsComplete: <#T##Int#>, stepsTotal: <#T##Int#>)
}

struct JourneyList: View {
	let journeys: [Journey]
	var body: some View {
		List {
			ForEach(journeys) { journey in
					
			}
		}
	}
}

struct JourneyCell: View {
	let color: Color
	let time: String
	let imageUrl: String
	let name: String
	let services: String
	let status: String
	let employee: String
	let paidStatus: String
	let stepsComplete: Int
	let stepsTotal: Int

	var body: some View {
		HStack {
			Rectangle.init().frame(width: 8).background(color)
			Text(time)
			Image(imageUrl)
			VStack {
				Text(name)
				Text(services)
				Text(status)
			}
			Image(systemName: "person")
			Text(employee)
			Image(systemName: "briefcase")
			Text(paidStatus)
			Ellipse()
				.fill(Color.blue)
				.frame(width: 100, height: 50)
		}
	}
}
