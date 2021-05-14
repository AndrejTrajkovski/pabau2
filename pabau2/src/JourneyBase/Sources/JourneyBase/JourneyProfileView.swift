import SwiftUI
import Util
import Model
import SwiftDate
import Avatar

public struct JourneyProfileView: View {
    let style: JourneyProfileViewStyle
    let viewState: ViewState
    public struct ViewState: Equatable {
//        let hasJourney: Bool
        let imageUrl: String?
        let name: String
        let services: String
        let employeeName: String
        let time: String
        let rooms: String
        let date: String
        let initials: String
    }
    
    public init(style: JourneyProfileViewStyle, viewState: JourneyProfileView.ViewState) {
        self.style = style
        self.viewState = viewState
    }
    
    public var body: some View {
        VStack {
            AvatarView(avatarUrl: viewState.imageUrl,
                       initials: viewState.initials,
                       font: nameFont,
                       bgColor: .accentColor)
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
    public init(appointment: Appointment?) {
        self.imageUrl = appointment?.clientPhoto
        self.name = appointment?.clientName ?? ""
        self.services = appointment?.service ?? ""
        self.employeeName = appointment?.employeeName ?? ""
        self.time = appointment?.start_date.toFormat("HH: mm") ?? ""
        self.rooms = "201, 202"
        self.date = appointment?.start_date.toFormat("MMMM dd yyyy") ?? ""
        self.initials = appointment?.employeeInitials ?? ""
    }
}

