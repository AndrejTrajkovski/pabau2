import SwiftUI
import ComposableArchitecture

enum ActiveCanvas {
	case drawing
	case injectables
}

struct SinglePhotoEditState: Equatable {
	var activeCanvas: ActiveCanvas
	var photo: PhotoViewModel
	var chosenIncrement: Double
	var chosenInjectable: Injectable
	
	var injectablesCanvas: InjectablesCanvasState {
		get {
			InjectablesCanvasState(
				photo: photo,
				chosenIncrement: chosenIncrement,
				chosenInjectable: chosenInjectable)
		}
		set {
			self.photo = newValue.photo
			self.chosenIncrement = newValue.chosenIncrement
			self.chosenInjectable = newValue.chosenInjectable
		}
	}
}

enum SinglePhotoEditAction: Equatable {
	case photoAndCanvas(PhotoAndCanvasAction)
	case injectablesCanvas(InjectablesCanvasAction)
}

struct SinglePhotoEdit: View {
	@State var photoSize: CGSize = .zero
	let store: Store<SinglePhotoEditState, SinglePhotoEditAction>
	var body: some View {
		WithViewStore(store.scope { $0.activeCanvas }) { viewStore in
			InjectablesCanvas(size: self.photoSize,
												store:
				self.store.scope(
					state: { $0.injectablesCanvas },
					action: { .injectablesCanvas($0) })
			)
				.frame(width: self.photoSize.width,
						 height: self.photoSize.height)
				.zIndex(viewStore.state == .injectables ? 1 : 0)
			PhotoAndCanvas(store:
				self.store.scope(state: { $0.photo },
										action: { .photoAndCanvas($0) }))
				.onPreferenceChange(PhotoSize.self) { size in
					self.photoSize = size
			}
				.zIndex(viewStore.state == .drawing ? 1 : 0)
		}
	}
}
