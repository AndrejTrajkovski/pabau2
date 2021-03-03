import SwiftUI
import Util
import ComposableArchitecture
import Model

public enum ClientCardTopAction: Equatable {
	case onMessage
	case onCall
	case onVideo
	case onEmail
}

struct ClientCardTop: View {

	let store: Store<Client, ClientCardTopAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				ClientAvatar(store: store.actionless)
					.frame(width: 84, height: 84)
				Text(viewStore.fullname)
					.font(Font.semibold24)
				ClientCardContactIcons(store: self.store.stateless)
			}
		}
	}
}

private struct ClientCardContactIcons: View {
	let store: Store<Void, ClientCardTopAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack(spacing: 32) {
				ContactButton(text: Texts.mobile,
											imageName: "message.circle.fill",
											onAction: {
												viewStore.send(.onMessage)
				})
				ContactButton(text: Texts.call,
											imageName: "phone.circle.fill",
											onAction: {
												viewStore.send(.onCall)
				})
				ContactButton(text: Texts.facetime,
											imageName: "video.circle.fill",
											onAction: {
												viewStore.send(.onVideo)
				})
				ContactButton(text: Texts.mail,
											imageName: "envelope.circle.fill",
											onAction: {
												viewStore.send(.onEmail)
				})
			}
		}
	}
}

private struct ContactButton: View {
	let text: String
	let imageName: String
	let onAction: () -> Void
	var body: some View {
		Button(action: onAction,
					 label: {
						VStack {
							Image(systemName: imageName)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 36, height: 36)
							Text(text)
								.foregroundColor(.accentColor)
								.font(Font.regular13)
								.fixedSize(horizontal: true, vertical: false)
						}
		}).frame(width: 36)
	}
}
