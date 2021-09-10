import SwiftUI
import ComposableArchitecture
import Model
import Util
import Form

public struct PhotoShareSelectItem: Equatable, Identifiable {
    enum PhotoShareSelectItemType: Equatable {
        case title(String)
        case subtitle
        case review
        case rating(CGFloat)

    }
    public let id = UUID()
    var type: PhotoShareSelectItemType = .title("")

    var photo: PhotoViewModel!
    var comparedPhoto: PhotoViewModel!
}

struct PhotoShareSelectState: Equatable {

    var rating: CGFloat = 4.0
    var photo: PhotoViewModel!
    var comparedPhoto: PhotoViewModel!

    init(photo: PhotoViewModel, comparedPhoto: PhotoViewModel) {
        self.photo = photo
        self.comparedPhoto = comparedPhoto

        items.append(PhotoShareSelectItem(type: .title("20 Day Difference"), photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .review, photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .rating(rating), photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .title("Botox Treatment"), photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .subtitle, photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .subtitle, photo: photo, comparedPhoto: comparedPhoto))

    }

    init() {

    }

    var items: [PhotoShareSelectItem] = []
    var selectedItem: PhotoShareSelectItem?
    var photoShareState: PhotoShareState = PhotoShareState()
    var isItemSelected: Bool = false
}

public enum PhotoShareSelectAction: Equatable {
    case selectedItem(PhotoShareSelectItem, Data)
    case shareAction(PhotoShareAction)
    case backButton
}

let photoShareSelectViewReducer: Reducer<PhotoShareSelectState, PhotoShareSelectAction, ClientsEnvironment> = Reducer.combine(
    photoShareViewReducer.pullback(
            state: \PhotoShareSelectState.photoShareState,
            action: /PhotoShareSelectAction.shareAction,
            environment: { $0 }
        ),

    Reducer { state, action, _ in
        switch action {
        case .selectedItem(let item, let imageData):
            state.selectedItem = item
            state.photoShareState = PhotoShareState(imageData: imageData)
            state.isItemSelected = true
        case .shareAction(.backButton):
            state.selectedItem = nil
            state.isItemSelected = false
        default:
            break
        }

        return .none
})

struct PhotoShareSelectView: View {

    let store: Store<PhotoShareSelectState, PhotoShareSelectAction>
	init(store: Store<PhotoShareSelectState, PhotoShareSelectAction>) {
		self.store = store
	}

    let layout = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {

        WithViewStore(self.store) { viewStore  in
            GeometryReader { geo in
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 10) {
                            ForEach(Array(viewStore.items)) { item in
                                let cellItemView = PhotoShareCellItemView(item: item)
                                    .frame(width: geo.size.width / 2 - 30,
                                           height: geo.size.height / 3 - 30)

                                cellItemView.onTapGesture {
                                    convertViewToData(view: cellItemView,
                                                      size: CGSize(width: geo.size.width / 2 - 30,
                                                                   height: geo.size.height / 3 - 30)) { (data) in
                                        if let imageData = data {
                                            viewStore.send(.selectedItem(item, imageData))
                                        }
                                    }
                                }
                            }
						}
					}.padding(20)
				if viewStore.photoShareState != nil {
					NavigationLink.emptyHidden(viewStore.isItemSelected,
											   PhotoShareView(store: self.store.scope(state: { $0.photoShareState},
																					  action: { PhotoShareSelectAction.shareAction($0) })
											   ))
				}
			}.navigationBarItems(
				leading: HStack {
					MyBackButton(text: Texts.back) {
                        viewStore.send(.backButton)
                    }}
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("Select Photo")
        }
    }

    func convertViewToData<V: View>(view: V, size: CGSize, completion: @escaping (Data?) -> Void) {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            completion(nil)
            return
        }
        let imageVC = UIHostingController(rootView: view.edgesIgnoringSafeArea(.all))
        imageVC.view.frame = CGRect(origin: .zero, size: size)
        DispatchQueue.main.async {
            rootVC.view.insertSubview(imageVC.view, at: 0)
            let uiImage = imageVC.view.renderedImage(size: size)
            imageVC.view.removeFromSuperview()
            completion(uiImage.pngData())
        }
    }

}
