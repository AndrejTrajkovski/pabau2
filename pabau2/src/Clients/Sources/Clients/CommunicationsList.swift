import Foundation
import SwiftUI
import Model
import Util
import ComposableArchitecture
import Avatar

struct CommunicationsList: ClientCardChild {
	let store: Store<ClientCardChildState<[Communication]>, GotClientListAction<[Communication]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach(viewStore.state.state.indices, id: \.self) { idx in
					CommunicationRow(comm: viewStore.state.state[idx])
				}
			}
		}
	}
}

struct CommunicationRow: View {
	let comm: Communication
	var body: some View {
		VStack(spacing: 0) {
            if Constants.isPad {
                ipadContentView
            } else {
                iphoneContentView
            }
		}
	}

    private var ipadContentView: some View {
        HStack {
            avatarView
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    ChannelIcon(channel: comm.channel)
                    Text(comm.title).font(.medium17).isRemoved(comm.title.isEmpty)
                    Spacer()
                    DateLabel(date: comm.date)
                }
                Text(comm.subtitle)
            }
        }
    }

    private var iphoneContentView: some View {
        HStack {
            avatarView
            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(comm.title).font(.medium17).isRemoved(comm.title.isEmpty)
                    DateLabel(date: comm.date)
                }
                Text(comm.subtitle)
            }
            Spacer()
            ChannelIcon(channel: comm.channel)
        }
    }

    private var avatarView: some View {
        AvatarView(
            avatarUrl: nil,
            initials: comm.initials,
            font: .regular18,
            bgColor: .accentColor
        )
        .frame(width: 55, height: 55)
        .padding()
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
