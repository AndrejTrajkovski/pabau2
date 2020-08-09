import SwiftUI
import ComposableArchitecture
import Form
import ASCollectionView
import Util

public let ccPhotosReducer: Reducer<CCPhotosState, CCPhotosAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[PhotoViewModel]>().reducer.pullback(
		state: \CCPhotosState.state,
		action: /CCPhotosAction.action,
		environment: { $0 }
	)
	,
	selectPhotosReducer.pullback(
		state: \CCPhotosState.selectPhotos,
		action: /CCPhotosAction.selectPhotos,
		environment: { $0 }
	)
)

public struct CCPhotosState: ClientCardChildParentState, Equatable {
	var state: ClientCardChildState<[PhotoViewModel]>
	var selectedIds: [PhotoVariantId]
	
	var selectPhotos: SelectPhotosState {
		get {
			SelectPhotosState.init(photosArray: state.state,
														 selectedIds: selectedIds)
		}
		set {
			self.state.state = newValue.photos.elements
			self.selectedIds = newValue.selectedIds
		}
	}
}

public enum CCPhotosAction: ClientCardChildParentAction, Equatable {
	case selectPhotos(SelectPhotosAction)
	case action(GotClientListAction<[PhotoViewModel]>)
	var action: GotClientListAction<[PhotoViewModel]>? {
		get {
			if case .action(let app) = self {
				return app
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue {
				self = .action(newValue)
			}
		}
	}
}

struct CCPhotos: ClientCardChild {
	let store: Store<CCPhotosState, CCPhotosAction>
	var body: some View {
		CCSelectPhotos(store:
			self.store.scope(state: { $0.selectPhotos },
											 action: { .selectPhotos($0) })
		)
	}
}

struct CCSelectPhotos: View {
	let store: Store<SelectPhotosState, SelectPhotosAction>
	@ObservedObject var viewStore: ViewStore<SelectPhotosState, SelectPhotosAction>

	init(store: Store<SelectPhotosState, SelectPhotosAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		ASCollectionView {
			[ClientCardPhotosAlbumSection(idArray: viewStore.state.photos).section]
		}.layout { sectionID in
			switch sectionID {
			case 0:
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 16,
										 lineSpacing: 16)
			default:
				fatalError()
			}
		}
	}
}

struct ClientCardPhotosAlbumSection {
	init (idArray: IdentifiedArrayOf<PhotoViewModel>) {
		self.photos = Dictionary.init(grouping: idArray.elements,
																	by: {
																		let date = Calendar.current.dateComponents([.day, .year, .month], from: $0.basePhoto.date)
																		return Calendar.current.date(from: date)!
		})
	}

	let photos: [Date: [PhotoViewModel]]
	var section: ASCollectionViewSection<Int> {
		ASCollectionViewSection(
			id: 0,
			data: self.photos.sorted(by: \.key),
			dataID: \.self.key) { photosByDate, context in
				AlbumCell(photos: Array(photosByDate.value), date: photosByDate.key)
		}
	}
}

struct AlbumCell: View {
	let photos: [PhotoViewModel]
	let date: Date

	var body: some View {
		ZStack(alignment: .bottom) {
			PhotoCell(photo: photos.first!)
			DateAndNumber(date: date, number: photos.count).offset(y: -16)
		}
	}
}

struct DateAndNumber: View {
	let date: Date
	let number: Int
	
	static let dateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy"
		return formatter
	}()
	
	var body: some View {
		HStack {
			NumberEclipse(text: String(number))
			Text(Self.dateFormat.string(from: date))
				.foregroundColor(.white)
				.font(.regular12)
				.padding(5)
				.frame(height: 20)
		}
		.background(RoundedCorners(color: Color.black.opacity(0.5),
															 tl: 25, tr: 25, bl: 25, br: 25))
	}
}
