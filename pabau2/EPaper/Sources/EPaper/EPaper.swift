import SwiftUI
import SDWebImageSwiftUI
import Model
import PencilKit
import ComposableArchitecture
import Form
import Tagged
import Combine

public struct EpaperState: Equatable {
    let epaperImages: [String]
    var activeImageIndex: Int = 0
    var canvasStateArray: [CanvasViewState] = []
    var shouldUpdate = false
    var imagesContainer: [UIImage] = []
    var mergedImages: [UIImage] = []
    
    public init(epaperImages: [String]) {
        self.epaperImages = epaperImages
        canvasStateArray = epaperImages.map { CanvasViewState(imageURL: $0,
                                                              isDisabled: false) }
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
    case didFinishedMergeImagesWithDrawings
    case photoUploadResponse
}

public struct EpaperEnvironment {
    var apiClient: FormAPI
    public init(apiClient: FormAPI) {
        self.apiClient = apiClient
    }
}

public let epaperReducer = Reducer<EpaperState, EpaperAction, EpaperEnvironment>.combine(
    .init { state, action, env in
        switch action {
        case .previousImage:
            state.activeImageIndex -= 1
        case .nextImage:
            if !state.epaperImages.isEmpty {
                if state.activeImageIndex < state.epaperImages.count - 1 {
                    state.activeImageIndex += 1
                }
            }
        case .update:
            state.shouldUpdate = true
            let mergedImages = CanvasHelper.mergeImagesWithDrawings(images: state.imagesContainer,
                                                        canvases: state.canvasStateArray.map { $0.canvasDrawingState.canvasView })
            state.mergedImages = mergedImages
            return Just(EpaperAction.didFinishedMergeImagesWithDrawings)
                .eraseToEffect()
        case .onAppear:
            return ImageDownloader()
                .downloadImages(urlStrings: state.epaperImages)
                .map { .didDownloadImages($0) }
                .eraseToEffect()
        case .didDownloadImages(let images):
            state.imagesContainer = images
        case .didFinishedMergeImagesWithDrawings:
            let clientId: Client.Id = Client.Id.init(rawValue: .right(12148231))
            let medicalUniqId = UUID().uuidString
            let params: [String: String] = [
                "contact_id": "\(clientId.description)",
                "medical_uniqid": "\(medicalUniqId)",
                "medical_form_id": "280232"
            ]
            
            return env.apiClient
                .uploadEpaperImages(images: state.mergedImages.map { $0.pngData()! }, params: params)
                .catchToEffect()
                .map { response in
                    switch response {
                    case .success(let voResponse):
                        print(voResponse)
                    case .failure(let error):
                        print(error)
                    }
                    return EpaperAction.photoUploadResponse
                }
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
).debug()

public struct EPaperView: View {

    public init(store: Store<EpaperState, EpaperAction>) {
        self.store = store
    }
    
    let store: Store<EpaperState, EpaperAction>
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {                
                VStack {
                    // Remove this before commit
                    if viewStore.shouldUpdate && !viewStore.imagesContainer.isEmpty { // for testing
                        List {
                            ForEach(viewStore.state.mergedImages, id: \.self) { image in
                                Image(uiImage: image)
                            }
                        }
                    } else {
                        PhotoCanvasView(store: self.store.scope(state: { $0.canvasStateArray[viewStore.activeImageIndex]},
                                                                    action: { EpaperAction.canvasAction(index: viewStore.activeImageIndex,
                                                                                                        action: $0)
                                                                    }
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
                        Button((viewStore.state.epaperImages.count - 1) == viewStore.state.activeImageIndex ? "Update" : "Next") {
                            (viewStore.state.epaperImages.count - 1 == viewStore.state.activeImageIndex) ? viewStore.send(.update) :
                            viewStore.send(.nextImage)
                        }
                    }
                }
                .navigationBarTitle("Page \(viewStore.state.activeImageIndex + 1) of \(viewStore.state.epaperImages.count)", displayMode: .inline)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
}


extension View {
    func printv( _ data : Any)-> EmptyView {
        print(data)
        return EmptyView()
       }
}
