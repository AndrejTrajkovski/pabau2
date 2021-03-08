import SwiftUI
import SDWebImageSwiftUI
import Model
import PencilKit
import ComposableArchitecture
import Form

public enum PhotoAndCanvasAction: Equatable {
    case onSave
    case onDrawingChange(PKDrawing)
}

public struct FormData: Equatable {
    var epaperImages: [String] = []
    
    public static let mockEpaper = FormData(epaperImages: ["https://prelive-crm.pabau.com/cdn/medical_images/3470/medical_photos/epaper_5bcee4590b611.jpg",
        "https://prelive-crm.pabau.com/cdn/medical_images/3470/medical_photos/epaper_5bcee4590b611.jpg"])
    
}

public struct EpaperState: Equatable {
    var formData: FormData
    var activeImageIndex: Int = 0
    var canvasStateArray: [CanvasViewState] = []
    var shouldUpdate = false
    var imagesContainer: [UIImage] = []
    var mergedImages: [UIImage] = []
    public init(formData: FormData) {
        self.formData = formData
        formData.epaperImages.forEach { imageUrl in
            let emptyState = CanvasViewState(
                photo: PhotoViewModel(NewPhoto(id: UUID(), image: UIImage(), date: Date())),
                isDisabled: false)
            canvasStateArray.append(emptyState)
        }
    }
    
    var isDisabledPreviousBtn: Bool {
        return activeImageIndex == 0
    }
}

public enum EpaperAction: Equatable {
    case nextImage
    case previousImage
    case update
    case canvasAction(index: Int, action: PhotoAndCanvasAction)
    case onAppear
    case didDownloadImages([UIImage])
}

public struct EpaperEnvironment {
    public init() { }
}

public let epaperReducer = Reducer<EpaperState, EpaperAction, EpaperEnvironment>.combine(
    .init { state, action, env in
        switch action {
        case .previousImage:
            state.activeImageIndex -= 1
        case .nextImage:
            if !state.formData.epaperImages.isEmpty {
                if state.activeImageIndex < state.formData.epaperImages.count - 1 {
                    state.activeImageIndex += 1
                }
            }
        case .update:
            state.shouldUpdate = true
            state.mergedImages = CanvasHelper.mergeImagesWithDrawings(images: state.imagesContainer,
                                                                    canvases: state.canvasStateArray.map { return $0.canvas })
        case .onAppear:
            return ImageDownloader()
                .downloadImages(urlStrings: state.formData.epaperImages)
                .map { .didDownloadImages($0) }
                .eraseToEffect()
        case .didDownloadImages(let images):
            state.imagesContainer = images
        default:
            break
        }
        return .none
    },
    canvasStateReducer.forEach(
        state: \.canvasStateArray,
        action: /EpaperAction.canvasAction(index:action:),
        environment: { _ in CanvasEnvironment() }
    )
)

public struct EPaperView: View {

    public init(store: Store<EpaperState, EpaperAction>) {
        self.store = store
    }
    
    let store: Store<EpaperState, EpaperAction>
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    if viewStore.shouldUpdate && !viewStore.imagesContainer.isEmpty { // for testing
                        List {
                            ForEach(viewStore.state.mergedImages, id: \.self) { image in
                                Image(uiImage: image)
                            }
                        }
                    } else {
                        WebImage(url: URL(string: viewStore.state.formData.epaperImages[viewStore.state.activeImageIndex])!)
                        CanvasView(store: self.store.scope(state: { $0.canvasStateArray[viewStore.activeImageIndex] },
                                                           action:  { EpaperAction.canvasAction(index: viewStore.activeImageIndex, action: $0)}
                        ))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                        Button("Close") { }
                    }
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        Button("Clear") { }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Previous") {
                            viewStore.send(.previousImage)
                        }.disabled(viewStore.state.isDisabledPreviousBtn)
                        Spacer()
                        Button((viewStore.state.formData.epaperImages.count - 1) == viewStore.state.activeImageIndex ? "Update" : "Next") {
                            (viewStore.state.formData.epaperImages.count - 1 == viewStore.state.activeImageIndex) ? viewStore.send(.update) :
                            viewStore.send(.nextImage)
                        }
                    }
                }
                .navigationBarTitle("Page \(viewStore.state.activeImageIndex + 1) of \(viewStore.state.formData.epaperImages.count)", displayMode: .inline)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
}
