import SwiftUI
import ComposableArchitecture
import Util

public let singleSelectImagesReducer = Reducer<SingleSelectImages, SingleSelectImagesAction, Any>.init { state, action, _ in
	switch action {
	case .didSelectIdx(let idx):
		state.selectedIdx = idx
	}
	return .none
}

public struct SingleSelectImages: Equatable {
	var images: [String]
	var selectedIdx: Int?
}

public enum SingleSelectImagesAction: Equatable {
	case didSelectIdx(Int)
}

struct SIngleSelectImagesField: View {
	
	let maxVisibleCells = 4
	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8
	
	var body: some View {
		EmptyView()
	}
}
