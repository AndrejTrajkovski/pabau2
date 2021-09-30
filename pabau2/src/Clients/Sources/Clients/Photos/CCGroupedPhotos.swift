import SwiftUI
import ComposableArchitecture
import Form
import ASCollectionView
import Util

struct CCGroupedPhotos: View {
	let store: Store<[Date: [PhotoViewModel]], CCPhotosAction>
	@ObservedObject var viewStore: ViewStore<[Date: [PhotoViewModel]], CCPhotosAction>

	init(store: Store<[Date: [PhotoViewModel]], CCPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		ASCollectionView {
			[CCGroupedSection(viewStore: viewStore).section]
		}.layout { sectionID in
			switch sectionID {
			case 0:
				return .grid(
                    layoutMode: .fixedNumberOfColumns(Constants.isPad ? 4 : 2),
                    itemSpacing: 16,
					lineSpacing: 16
                )
			default:
				fatalError()
			}
		}
	}
}

struct CCGroupedSection {
	let viewStore: ViewStore<[Date: [PhotoViewModel]], CCPhotosAction>
	init (viewStore: ViewStore<[Date: [PhotoViewModel]], CCPhotosAction>) {
		self.viewStore = viewStore
	}

//	let photos: [Date: [PhotoViewModel]]
	var section: ASCollectionViewSection<Int> {
		ASCollectionViewSection(
			id: 0,
			data: self.viewStore.state.sorted(by: \.key),
			dataID: \.self.key) { photosByDate, _ in
				GroupedPhotosCell(photos: Array(photosByDate.value), date: photosByDate.key)
					.onTapGesture {
						self.viewStore.send(.onSelectDate(photosByDate.key))
				}
		}
	}
}

struct GroupedPhotosCell: View {
	let photos: [PhotoViewModel]
	let date: Date

	var body: some View {
		ZStack(alignment: .bottom) {
            PhotoCell(photo: photos.first!, shouldShowThumbnail: true)
			DateAndNumber(date: date, number: photos.count).offset(y: -16)
		}
	}
}
