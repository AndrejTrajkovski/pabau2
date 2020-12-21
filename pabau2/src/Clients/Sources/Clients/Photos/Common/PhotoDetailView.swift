import SwiftUI
import ComposableArchitecture
import Form
import Util


class PhotoDetailState: Equatable {
    static func == (lhs: PhotoDetailState, rhs: PhotoDetailState) -> Bool {
        return lhs.photo == rhs.photo
    }
    
    var photo: PhotoViewModel
    
    init(photo: PhotoViewModel, changes: MagnificationZoom) {
        self.photo = photo
        
        self.dragOffset = changes.dragOffset
        self.position = changes.position
        self.currentMagnification = changes.currentMagnification
        self.pinchMagnification = changes.pinchMagnification
    }
    var isSelected: Bool = false
    
    var date: Date {
        get {
            photo.basePhoto.date
        }
    }
    var changes: MagnificationZoom {
        set {
            dragOffset = newValue.dragOffset
            position = newValue.position
            currentMagnification = newValue.currentMagnification
            pinchMagnification = newValue.pinchMagnification
        }
        get {
            MagnificationZoom()
        }
        
    }
    
    var dragOffset: CGSize = .zero
    var position: CGSize = .zero
    var currentMagnification: CGFloat = 1
    var pinchMagnification: CGFloat = 1
}

public enum PhotoChangesAction: Equatable {
    case onChangeDragOffset(CGSize)
    case onEndedDrag(CGSize)
    case onChangePinchMagnification(CGFloat)
    case onEndedMagnification(CGFloat)
    case onTappedToZoom
    case onSelect
}

var changesPhotoReducer = Reducer<PhotoDetailState, PhotoChangesAction, ClientsEnvironment> { state, action, environment in
    switch action {
    case .onTappedToZoom:
        break
    default: break
    }
    return .none
}

struct PhotoDetailViewSecond: View {
    
    @ObservedObject var viewStore: ViewStore<PhotoDetailState, PhotoChangesAction>
    init(store: Store<PhotoDetailState, PhotoChangesAction>, positionCompare: Int = 0) {
        viewStore = ViewStore(store)
    }
    
    @GestureState var pinchMagnification: CGFloat = 1
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
    
    var tapGestureSelect: some Gesture {
        TapGesture(count: 1)
            .onEnded({
                viewStore.send(.onSelect)
            })
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                UIScrollViewWrapper {
                    PhotoDetailCell(photo: viewStore.photo)
                                .frame(width: proxy.size.width * (viewStore.pinchMagnification * viewStore.currentMagnification),
                                       height: proxy.size.height * (viewStore.pinchMagnification * viewStore.currentMagnification))
                                .gesture(magnificationGest)
                                .gesture(tapGesture)
                                .gesture(tapGestureSelect)
                        
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
