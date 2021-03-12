import SwiftUI
import ComposableArchitecture
import Model
import Util
import SDWebImageSwiftUI

public enum ClientRowAction: Equatable {
	case onSelectClient
    case onAppear
}

struct ClientListRow: View {
	let store: Store<Client, ClientRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
                if let avatarURL = viewStore.avatar {
                    WebImage(url: URL(string: avatarURL))
                        .resizable()
                        .placeholder(Image(systemName: "person.circle.fill"))
                        .clipShape(Circle())
                        .frame(width: 55, height: 55)
                } else {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 55, height: 55)
                        .overlay(
                            ZStack {
                                Text(viewStore.initials.uppercased())
                                    .foregroundColor(.white)
                                    .font(.regular18)
                            }
                        )
                }
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
