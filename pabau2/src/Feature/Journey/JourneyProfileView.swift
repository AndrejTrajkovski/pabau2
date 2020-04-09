import SwiftUI
import Util
import Model
import SwiftDate

struct JourneyProfileView: View {
	let style: JourneyProfileViewStyle
	let viewState: ViewState
	struct ViewState: Equatable {
//		let hasJourney: Bool
		let imageUrl: String
		let name: String
		let services: String
		let employeeName: String
		let time: String
		let rooms: String
	}
	var body: some View {
		VStack {
			Image(viewState.imageUrl)
				.resizable()
				.frame(width: 84, height: 84)
				.clipShape(Circle())
			Text(viewState.name).font(.semibold24)
			Text(viewState.services).foregroundColor(.gray838383).font(.regular20)
			Text(viewState.employeeName).foregroundColor(.blue2).font(.regular15)
			if self.style == .long {
				HStack {
					IconAndText(Image(systemName: "clock"), viewState.time, .gray140)
					IconAndText(Image("ico-journey-room"), viewState.rooms, .gray140)
				}
			}
		}
	}
}

extension JourneyProfileView.ViewState {
	init(journey: Journey?) {
		self.imageUrl = journey?.patient.avatar ?? "placeholder"
		self.name = (journey?.patient.firstName ?? "") + " " + (journey?.patient.lastName ?? "")
		self.services = journey?.servicesString ?? ""
		self.employeeName = journey?.employee.name ?? ""
		self.time = journey?.appointments.first.from.toFormat("HH: mm") ?? ""
		self.rooms = "201, 202"
//		self.hasJourney = journey != nil
	}
}
