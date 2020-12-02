import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailView: View {

    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    @ObservedObject var viewStore: ViewStore<PhotoCompareState, PhotoCompareAction>
    init(store: Store<PhotoCompareState, PhotoCompareAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }
    
    @GestureState var pinchMagnification: CGFloat = 1
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if viewStore.currentMagnification >= 1.2 {
                    viewStore.send(.onChangeDragOffset(value.translation))
                }
            }
            .onEnded { value in
                if viewStore.currentMagnification >= 1.2 {
                    viewStore.send(.onEndedDrag(value.translation))
                }
            }
    }
    
    var magnificationGest: some Gesture {
        MagnificationGesture()
            .updating($pinchMagnification, body: { value, state, _ in
                if value > 1 {
                    state = value
                    viewStore.send(.onChangePinchMagnification(state))
                }
            })
            .onEnded( { value in
                    if value > 1 {
                        viewStore.send(.onEndedMagnification(value))
                    }
                })
    }
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded({
                viewStore.send(.onTappedToZoom)
            })
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let photo = viewStore.selectedPhoto {
                        PhotoDetailCell(photo: photo)
                            .offset(x: viewStore.dragOffset.width + viewStore.position.width, y: viewStore.dragOffset.height + viewStore.position.height)
                            .scaleEffect(viewStore.pinchMagnification * viewStore.currentMagnification)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .gesture(drag)
                            .gesture(magnificationGest)
                            .gesture(tapGesture)
                            
                }
                VStack {
                    Spacer()
                    Text("Today")
                        .font(.regular32)
                        .foregroundColor(.white)
                    if let date = viewStore.date {
                        ZStack {
                            DayMonthYear(date: date)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                }
            }.clipped()
        }
    }
}

public struct PhotoDetailCell: View {
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
