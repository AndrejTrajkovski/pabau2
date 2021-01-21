import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailState: Equatable {
    let photo: PhotoViewModel
    let side: ActiveSide
	var dragOffset: CGSize
	var position: CGSize
	var currentMagnification: CGFloat
	var pinchMagnification: CGFloat
}

public enum PhotoChangesAction: Equatable {
    case onChangeDragOffset(CGSize)
    case onEndedDrag(CGSize)
    case onChangePinchMagnification(CGFloat)
    case onEndedMagnification(CGFloat)
    case onTappedToZoom
    case onSelect(ActiveSide)
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
            .onEnded({ value in
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
                viewStore.send(.onSelect(viewStore.side))
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
                    TimeIntervalSinceView(creationDate: viewStore.photo.basePhoto.date)
                        .font(.regular32)
                        .foregroundColor(.white)

                    if let date = viewStore.photo.basePhoto.date {
                        Spacer()
                            .frame(height: 10)
                        ZStack {
                            DayMonthYear(date: date, foregroundColorImage: .white)
                                .padding([.top, .bottom], 5)
                                .padding([.leading, .trailing], 15)
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
