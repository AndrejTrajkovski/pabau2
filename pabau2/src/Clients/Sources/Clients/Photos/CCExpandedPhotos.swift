import SwiftUI
import ComposableArchitecture
import ASCollectionView
import Form

struct CCExpandedPhotos: View {
	let store: Store<CCPhotosState, CCPhotosAction>
	@ObservedObject var viewStore: ViewStore<CCPhotosState, CCPhotosAction>

	init(store: Store<CCPhotosState, CCPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("CCExpandedPhotos")
		return ASCollectionView(sections: viewStore.state.selectedDate == nil ? sections : [selectedDateSection])
			.layout { _ in
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 16,
										 lineSpacing: 16)
		}
	}
	
	var selectedDateSection: ASCollectionViewSection<Date> {
		ExpandedPhotosSection(date: viewStore.state.selectedDate!,
							  photos: viewStore.state.childState.state[viewStore.state.selectedDate!] ?? [],
							  viewStore: viewStore).section
	}
}

struct ExpandedPhotosSection {
	let date: Date
	let photos: [PhotoViewModel]
	let viewStore: ViewStore<CCPhotosState, CCPhotosAction>
	
	var section: ASCollectionViewSection<Date> {
		ASCollectionViewSection(
			id: date,
			data: self.photos) { photo, _ in
			PhotoCell(photo: photo)
				.onTapGesture {
					self.viewStore.send(.didTouchPhoto(photo.id))
				}
		}
		.sectionHeader {
			HStack {
				DateAndNumber(date: date, number: photos.count)
				Spacer()
			}.padding(.leading, 32)
		}
	}
}
