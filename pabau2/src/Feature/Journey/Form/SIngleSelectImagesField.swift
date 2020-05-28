import SwiftUI
import ComposableArchitecture
import Util
import ASCollectionView

public let singleSelectImagesReducer = Reducer<SingleSelectImages, SingleSelectImagesAction, Any>.init { state, action, _ in
	switch action {
	case .didSelectIdx(let idx):
		state.selectedIdx = state.selectedIdx == idx ? nil : idx
	}
	return .none
}

public struct ImageUrl: Identifiable, Hashable {
	public var id: String { return title }
	let title: String

	init(_ title: String) {
		self.title = title
	}
}

public struct SingleSelectImages: Equatable {
	var images: [ImageUrl]
	var selectedIdx: Int?

	func isSelected(url: ImageUrl) -> Bool {
		return self.images.firstIndex(of: url) == selectedIdx
	}
}

public enum SingleSelectImagesAction: Equatable {
	case didSelectIdx(Int)
}

struct AftercareImagesSection {
	let store: Store<SingleSelectImages, SingleSelectImagesAction>
	@ObservedObject var viewStore: ViewStore<SingleSelectImages, SingleSelectImagesAction>

	public init(store: Store<SingleSelectImages, SingleSelectImagesAction>,
							title: String) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	func makeSection() -> ASCollectionViewSection<Int> {
		return ASCollectionViewSection(
			id: 1,
			data: self.viewStore.state.images,
			dataID: \.self) { imageUrl, context in
				return GridCell(title: imageUrl.title,
												isSelected: self.viewStore.state.isSelected(url: imageUrl))
					.onTapGesture {
						self.viewStore.send(.didSelectIdx(context.index))
				}
		}
		.sectionHeader { AftercareHeader(title) }
	}
}

struct GridCell: View {
	let title: String
	let isSelected: Bool
	var body: some View {
		Image(title)
		.resizable()
		.aspectRatio(contentMode: .fit)
		.padding(8)
		.border(isSelected ? Color.accentColor : Color.clear, width: 8.0)
	}
}
