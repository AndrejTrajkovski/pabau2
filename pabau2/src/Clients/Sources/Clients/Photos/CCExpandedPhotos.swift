import SwiftUI
import ComposableArchitecture
import ASCollectionView
import Form

struct CCExpandedPhotosState: Equatable {
    let selectedDate: Date
    let photos: [PhotoViewModel]
}

struct CCExpandedPhotos: View {
	let store: Store<CCExpandedPhotosState, CCPhotosAction>
	@ObservedObject var viewStore: ViewStore<CCExpandedPhotosState, CCPhotosAction>

	init(store: Store<CCExpandedPhotosState, CCPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("CCExpandedPhotos")
        
		return ASCollectionView(sections: [selectedDateSection])
			.layout { _ in
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 16,
										 lineSpacing: 16)
		}
	}
	
	var selectedDateSection: ASCollectionViewSection<Date> {
		ExpandedPhotosSection(date: viewStore.selectedDate,
                              photos: viewStore.photos,
                              action: { viewStore.send(.didTouchPhoto($0)) }).section
	}
}

struct ExpandedPhotosSection {
	let date: Date
	let photos: [PhotoViewModel]
    let action: (PhotoVariantId) -> Void
    
	var section: ASCollectionViewSection<Date> {
		ASCollectionViewSection(
			id: date,
			data: self.photos) { photo, _ in
            PhotoCell(photo: photo)
                .padding()
                .onTapGesture { action(photo.basePhoto.id) }
		}
		.sectionHeader {
			HStack {
				DateAndNumber(date: date, number: photos.count)
				Spacer()
			}.padding(.leading, 32)
		}
	}
}
