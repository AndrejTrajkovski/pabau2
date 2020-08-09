import SwiftUI
import ComposableArchitecture

public let stencilsReducer = Reducer<StencilsState, StencilsAction, FormEnvironment>.init { state, action, _ in
	switch action {
	case .didSelectStencilIdx(let idx):
		state.selectedStencilIdx = idx
	}
	return .none
}

public struct StencilsState: Equatable {
	var stencils: [String]
	var selectedStencilIdx: Int?
}

public enum StencilsAction: Equatable {
	case didSelectStencilIdx(Int)
}

struct StencilsCollection: View {
	let store: Store<StencilsState, StencilsAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				ForEach(viewStore.state.stencils.indices) { idx in
					Image(viewStore.state.stencils[idx])
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 62, height: 74)
						.onTapGesture {
							viewStore.send(.didSelectStencilIdx(idx))
					}
				}
			}.padding()
		}
	}
}
