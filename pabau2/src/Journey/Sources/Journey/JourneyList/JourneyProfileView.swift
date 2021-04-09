import SwiftUI
import Util
import Model
import SwiftDate

struct JourneyProfileView: View {
	let style: JourneyProfileViewStyle
	let viewState: ViewState
	struct ViewState: Equatable {
//		let hasJourney: Bool
		let imageUrl: String?
		let name: String
		let services: String
		let employeeName: String
		let time: String
		let rooms: String
		let date: String
	}
	var body: some View {
		VStack {
			Group {
				if viewState.imageUrl != nil {
					Image(viewState.imageUrl!).resizable().scaledToFill().clipShape(Circle())
				} else {
					Image(systemName: "person").resizable()
				}
			}
			.frame(width: profileImageRadius, height: profileImageRadius)
			Text(viewState.name).font(nameFont)
			Text(viewState.services).foregroundColor(.gray838383).font(serviceFont)
			if self.style == .short {
				Text(viewState.date).foregroundColor(.gray838383).font(.regular14)
			}
			if self.style == .long {
				Text(viewState.employeeName).foregroundColor(.blue2).font(.regular15)
			}
			if self.style == .long {
				HStack {
					IconAndText(Image(systemName: "clock"), viewState.time, .gray140)
					IconAndText(Image("ico-journey-room"), viewState.rooms, .gray140)
				}
			}
		}
	}

	var serviceFont: Font {
		style == .long ? .regular20 : .regular15
	}

	var nameFont: Font {
		style == .long ? .semibold24 : .semibold22
	}

	var profileImageRadius: CGFloat {
		style == .long ? 84 : 46
	}
}

extension JourneyProfileView.ViewState {
	init(journey: Journey?) {
		self.imageUrl = journey?.first?.clientPhoto
		self.name = journey?.first?.clientName ?? ""
		self.services = journey?.servicesString ?? ""
		self.employeeName = journey?.first?.employeeName ?? ""
		self.time = journey?.first?.start_date.toFormat("HH: mm") ?? ""
		self.rooms = "201, 202"
		self.date = journey?.first?.start_date.toFormat("MMMM dd yyyy") ?? ""
	}
}
