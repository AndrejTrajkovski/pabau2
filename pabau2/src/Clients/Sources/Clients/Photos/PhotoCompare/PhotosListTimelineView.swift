import SwiftUI
import ComposableArchitecture
import Form
import Model
import SDWebImageSwiftUI

struct PhotosListTimelineView: View {

    let store: Store<PhotoCompareState, PhotoCompareAction>
    let layout = [GridItem(.flexible())]

	struct State: Equatable {
		let photos: [PhotoViewModel]
        let selectedPhotoId: PhotoVariantId

		init(state: PhotoCompareState) {
			self.photos = state.photos.flatMap(\.value)
			self.selectedPhotoId = state.getSelectedId()
		}
    }

    var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            VStack {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 24) {
						ForEach(viewStore.photos) { item in
                            Button(action: {
								viewStore.send(.didChangeSelectedPhoto(id: item.id))
                            }) {
                                ZStack {
									TimelinePhotoCell(photo: item)
                                    .frame(width: 90, height: 110)
                                }
								.border(viewStore.selectedPhotoId == item.id ? Color.blue : Color.clear, width: 2)
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 40, height: 110)

            }.frame(height: 150)
        }
    }
}

public struct TimelinePhotoCell: View {
    let photo: PhotoViewModel

    public init(photo: PhotoViewModel) {
        self.photo = photo
    }

    public var body: some View {
        switch photo.basePhoto {
        case .saved(let savedPhoto):
            SavedPhotoCell(savedPhoto: savedPhoto, shouldShowThumbnail: true)
        case .new(let newPhoto):
            NewTimelinePhotoCell(newPhoto: newPhoto)
        }
    }
}

struct NewTimelinePhotoCell: View {
    let newPhoto: NewPhoto
    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: newPhoto.image)
                .resizable()
                .aspectRatio((
                    newPhoto.image.size.width / newPhoto.image.size.height),
                                         contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
    }
}
