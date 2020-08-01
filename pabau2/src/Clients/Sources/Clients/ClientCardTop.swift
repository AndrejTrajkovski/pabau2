import SwiftUI
import Util

public enum ClientCardTopAction: Equatable {
	case onMessage
	case onCall
	case onVideo
	case onEmail
}

struct ClientCardTop: View {

	let store: Store<Client, ClientCardTopAction>

	var body: some View {
		ViewStore(store) { viewStore in
			VStack {
				AvatarView(avatarUrl: viewStore.avatar,
									 initials: viewStore.initials,
									 font: .regular18,
									 bgColor: .accentColor)
					.frame(width: 50, height: 50)
				Text(viewStore.fullname)
				ClientCardContactIcons(store:self.store.stateless)
			}
		}
	}
}

struct ClientCardContactIcons: View {
	let store: Store<Void, ClientCardTopAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Button(action: {
					viewStore.send(.onMessage)
				}, label: {
					Image(systemName: "message.circle.fill")
				})
				Button(action: {
					viewStore.send(.onCall)
				}, label: {
					Image(systemName: "phone.circle.fill")
				})
				Button(action: {
					viewStore.send(.onVideo)
				}, label: {
					Image(systemName: "video.circle.fill")
				})
				Button(action: {
					viewStore.send(.onEmail)
				}, label: {
					Image(systemName: "envelope.circle.fill")
				})
			}
		}
	}
}
