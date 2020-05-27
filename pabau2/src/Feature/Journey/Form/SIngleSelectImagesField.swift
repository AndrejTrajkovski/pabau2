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

struct SIngleSelectImagesField: View {
	let store: Store<SingleSelectImages, SingleSelectImagesAction>
	@ObservedObject var viewStore: ViewStore<SingleSelectImages, SingleSelectImagesAction>

	public init(store: Store<SingleSelectImages, SingleSelectImagesAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	@State private var height: CGFloat?
	var body: some View {
		EmptyView()
//		QGrid(viewStore.state.images,
//					columns: 4,
//					isScrollable: false) { imageUrl in
//						GridCell(title: imageUrl.title,
//										 isSelected: self.viewStore.state.isSelected(url: imageUrl)
//						).onTapGesture {
//							self.viewStore.send(
//								.didSelectIdx(
//									self.viewStore.state.images.firstIndex(of: imageUrl)!)
//							)
//						}
//		}
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
