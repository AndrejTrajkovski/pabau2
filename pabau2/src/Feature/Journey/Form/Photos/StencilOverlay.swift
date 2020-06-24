import SwiftUI
import ComposableArchitecture

typealias Stencil = String

struct StencilOverlayState {
	var stencils: [Stencil]
	var selectedStencilIdx: Int?
	var isShowingStencils: Bool
}

struct StencilOverlay: View {
	let store: Store<StencilOverlayState, Never>
	struct State: Equatable {
		let selectedStencil: Stencil?
		let isShowingStencils: Bool
	}
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			if viewStore.state.isShowingStencils && viewStore.state.selectedStencil != nil {
				Image(viewStore.state.selectedStencil!)
					.resizable()
					.frame(width: 100, height: 100)
			} else {
				EmptyView()
			}
		}
	}
}

extension StencilOverlay.State {
	init(state: StencilOverlayState) {
		self.isShowingStencils = state.isShowingStencils
		self.selectedStencil = state.selectedStencilIdx.map {
			 state.stencils[$0]
		}
	}
}
