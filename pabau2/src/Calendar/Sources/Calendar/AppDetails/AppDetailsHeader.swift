import SwiftUI
import Util
import ComposableArchitecture
import Model

struct AppDetailsHeader: View {
	
	@ObservedObject var viewStore: ViewStore<ViewState, Never>
	
	init (store: Store<AppDetailsState, AppDetailsAction>) {
		self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)).actionless)
	}
	
	struct ViewState: Equatable {
		let imageUrl: String?
		let name: String
		let statusColor: String
		let statusDesc: String
	}
	
	var body: some View {
		VStack {
			if let imageU = viewStore.imageUrl {
				Image(imageU)
					.resizable()
					.scaledToFill()
					.clipShape(Circle())
					.frame(width: 84, height: 84)
			} else {
				Image(systemName: "person")
					.resizable()
			}
			Text(viewStore.name).font(.semibold24)
			HStack {
				Circle().fill(Color.init(hex: viewStore.statusColor))
					.frame(width: 12, height: 12)
				Text(viewStore.statusDesc).font(.regular16)
			}
		}
	}
}

extension AppDetailsHeader.ViewState {

	init(state: AppDetailsState) {
		self.imageUrl = state.app.customerPhoto
		self.name = state.app.customerName ?? ""
		self.statusColor = state.app.status?.color ?? "000000"
		self.statusDesc = state.app.status?.name ?? "No Info"
	}
}
