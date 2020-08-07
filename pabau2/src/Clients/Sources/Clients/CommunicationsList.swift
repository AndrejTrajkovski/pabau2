import Foundation
import SwiftUI
import Model
import Util

struct CommunicationsList: ClientCardChild {
	var state: [Communication]
	var body: some View {
		List {
			ForEach(self.state.indices, id: \.self) { idx in
				CommunicationRow(comm: self.state[idx])
			}
		}
	}
}

struct CommunicationRow: View {
	let comm: Communication
	var body: some View {
		VStack(spacing: 0){
			HStack {
				AvatarView(avatarUrl: nil,
									 initials: comm.initials,
									 font: .regular18,
									 bgColor: .accentColor)
					.frame(width: 55, height: 55)
					.padding()
				VStack(alignment: .leading) {
					HStack {
						ChannelIcon(channel: comm.channel)
						Text(comm.title).font(.medium17)
						Spacer()
						DateLabel(date: comm.date)
					}
					Text(comm.subtitle)
				}
			}
			Divider()
		}
	}
}

struct ChannelIcon: View {
	let channel: CommunicationChannel
	var body: some View {
		Image(systemName: channel == .sms ? "message.circle" : "envelope.circle")
			.resizable()
			.frame(width: 26, height: 26)
			.foregroundColor(.accentColor)
	}
}
