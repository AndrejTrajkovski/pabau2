import SwiftUI
import Util
import Model
import SwiftDate

func view(journey: Journey) -> ProfileView {
	ProfileView.init(
		imageUrl: journey.patient.avatar ?? "placeholder",
		name: journey.patient.firstName + journey.patient.lastName,
		services: journey.servicesString,
		employeeName: journey.employee.name,
		time: journey.appointments.first.from.toFormat("HH: mm"),
		rooms: "201, 202")
}

struct ProfileView: View {
	let imageUrl: String
	let name: String
	let services: String
	let employeeName: String
	let time: String
	let rooms: String
	var body: some View {
		VStack {
			Image(imageUrl)
				.resizable()
				.frame(width: 84, height: 84)
				.clipShape(Circle())
			Text(name).font(.semibold24)
			Text(services).foregroundColor(.gray838383).font(.regular20)
			Text(employeeName).foregroundColor(.blue2).font(.regular15)
			HStack {
				IconAndText(Image(systemName: "clock"), time)
				IconAndText(Image("ico-journey-room"), rooms)
			}
		}
	}
}
