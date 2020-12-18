import SwiftUI
import ComposableArchitecture
import Model
import Util

public enum ClientRowAction: Equatable {
	case onSelectClient
    case onAppear
}

struct ClientListRow: View {
	let store: Store<Client, ClientRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				AvatarView(avatarUrl: viewStore.avatar,
									 initials: viewStore.initials,
									 font: .regular18,
									 bgColor: .accentColor)
					.frame(width: 55, height: 55)
				VStack(alignment: .leading) {
					Text(viewStore.fullname).font(.headline)
					Text(viewStore.email ?? "").font(.regular12)
				}
				Spacer()
			}.onTapGesture {
				viewStore.send(.onSelectClient)
            }.onAppear {
                viewStore.send(.onAppear)
			}
		}
	}
}

extension Client {

	var fullname: String {
		return "\(self.firstName) \(self.lastName)"
	}

	var initials: String {
		return String(self.firstName.first ?? Character.init("")) + String(self.lastName.first ?? Character.init(""))
	}
}
