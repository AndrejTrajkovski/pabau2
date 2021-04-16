import SwiftUI
import ComposableArchitecture
import Model
import Avatar

public struct ClientAvatar: View {
	
	public init(store: Store<Client, Never>) {
		self.store = store
	}
	
	let store: Store<Client, Never>
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			AvatarView(avatarUrl: viewStore.avatar,
					   initials: viewStore.initials,
					   font: .semibold24,
					   bgColor: .accentColor)
				.frame(width: 84, height: 84)
		}
	}
}
