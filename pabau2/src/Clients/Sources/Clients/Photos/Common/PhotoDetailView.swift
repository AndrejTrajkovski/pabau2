import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailView: View {

    let store: Store<PhotoCompareState, PhotoCompareAction>
    private var positionCompare: Int = 0
    @ObservedObject var viewStore: ViewStore<PhotoCompareState, PhotoCompareAction>
    init(store: Store<PhotoCompareState, PhotoCompareAction>, positionCompare: Int = 0) {
        self.store = store
        viewStore = ViewStore(store)
        self.positionCompare = positionCompare
        UIScrollView.appearance().bounces = false
    }
    
    @GestureState var pinchMagnification: CGFloat = 1
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if viewStore.currentMagnification > 1 {
                    viewStore.send(.onChangeDragOffset(value.translation))
                }
            }
            .onEnded { value in
                if viewStore.currentMagnification > 1 {
                    viewStore.send(.onEndedDrag(value.translation))
                }
            }
    }
    
    var magnificationGest: some Gesture {
        MagnificationGesture()
            .updating($pinchMagnification, body: { value, state, _ in
                    state = value
                    viewStore.send(.onChangePinchMagnification(state))
            })
            .onEnded( { value in
                    viewStore.send(.onEndedMagnification(value))
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
                if let photo = viewStore.photosCompares[self.positionCompare] {
                    
                        // Implementaton using drag gestura and magnification gesture
                        // this it's not completed because it has some issues with dragging 
                        /*
                        PhotoDetailCell(photo: photo!)
                            .offset(x: viewStore.dragOffset.width + viewStore.position.width,
                                    y: viewStore.dragOffset.height + viewStore.position.height)
                            .scaleEffect(viewStore.pinchMagnification * viewStore.currentMagnification)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .gesture(drag)
                            .gesture(magnificationGest)
                            .gesture(tapGesture)
                    */
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        PhotoDetailCell(photo: photo!)
                            .frame(width: proxy.size.width * (viewStore.pinchMagnification * viewStore.currentMagnification), height: proxy.size.height * (viewStore.pinchMagnification * viewStore.currentMagnification))
                            .gesture(magnificationGest)
                            .gesture(tapGesture)
                    }
                }
                VStack {
                    Spacer()
                    Text("Today")
                        .font(.regular32)
                        .foregroundColor(.white)
                    
                    if let date = viewStore.date {
                        Spacer()
                            .frame(height: 10)
                        ZStack {
                            DayMonthYear(date: date, foregroundColorImage: .white)
                                .padding([.top, .bottom] , 5)
                                .padding([.leading, .trailing] , 15)
                                .background(RoundedCorners(color: Color.black.opacity(0.5),
                                                                                     tl: 25, tr: 25, bl: 25, br: 25))
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
