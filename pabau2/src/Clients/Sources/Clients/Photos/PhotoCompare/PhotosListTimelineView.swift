import SwiftUI
import ComposableArchitecture
import Form
import Model

struct PhotosListTimelineView: View {
    
    let store: Store<PhotoCompareState, PhotoCompareAction>
    var layout = [GridItem(.flexible())]
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 24) {
                        ForEach(viewStore.photos) { item in
                            Button(action: {
                                viewStore.send(.didChangeSelectedPhoto(item.id))
                            }) {
                                ZStack {
                                TimelinePhotoCell(photo: item)
                                    .frame(width: 90, height: 110)
                                }
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
        Group {
            if extract(case: Photo.saved, from: photo.basePhoto) != nil {
                SavedTimelinePhotoCell(savedPhoto: extract(case: Photo.saved, from: photo.basePhoto)!)
            } else if extract(case: Photo.new, from: photo.basePhoto) != nil {
                NewTimelinePhotoCell(newPhoto: extract(case: Photo.new, from: photo.basePhoto)!)
            }
        }
    }
}


struct SavedTimelinePhotoCell: View {
    let savedPhoto: SavedPhoto
    var body: some View {
        GeometryReader { proxy in
            Image(savedPhoto.url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
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
