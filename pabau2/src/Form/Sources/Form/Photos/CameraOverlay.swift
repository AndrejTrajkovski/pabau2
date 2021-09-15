import SwiftUI
import ComposableArchitecture
import Model

public struct CameraOverlayState: Equatable {
	var photos: IdentifiedArrayOf<PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isCameraActive: Bool
	var stencils: [Stencil]
	var selectedStencilIdx: Int?
	var isShowingStencils: Bool
	var isShowingPhotoLib: Bool
	var isFlashOn: Bool
	var frontOrRear: UIImagePickerController.CameraDevice
	var allInjectables: IdentifiedArrayOf<Injectable>
}

public enum CameraOverlayAction: Equatable {
	case onToggleStencils
	case onOpenPhotosLibrary
	case onClosePhotosLibrary
	case didTakePhotos([UIImage])
	case closeCamera
	case stencils(StencilsAction)
	case onToggleFlash
	case toggleFrontRearCamera
}

private enum BottomCollectionType {
	case stencils
	case photos
}

let cameraOverlayReducer: Reducer<CameraOverlayState, CameraOverlayAction, FormEnvironment> =
	.combine(
		stencilsReducer.pullback(
			state: \CameraOverlayState.stencilsState,
			action: /CameraOverlayAction.stencils,
			environment: { $0 }),
		.init { state, action, _ in
			switch action {
			case .onOpenPhotosLibrary:
				state.isShowingPhotoLib = true
			case .onClosePhotosLibrary:
				state.isShowingPhotoLib = false
			case .didTakePhotos(let images):
				let newPhotos = images.map {
					PhotoViewModel(NewPhoto.init(id: UUID(), image: $0, date: Date()))
				}
				guard !newPhotos.isEmpty else { break }
                let result = state.photos + newPhotos
                state.photos = IdentifiedArray(uniqueElements: result)
//				state.photos.insert(contentsOf: newPhotos, at: state.photos.count)
				state.editingPhotoId = newPhotos.last!.id
			case .closeCamera:
				state.isCameraActive = false
			case .onToggleStencils:
				state.isShowingStencils.toggle()
			case .onToggleFlash:
				state.isFlashOn.toggle()
			case .toggleFrontRearCamera:
				state.frontOrRear.toggle()
			case .stencils:
				break
			}
			return .none
		}
)

struct CameraOverlay: View {
	let store: Store<CameraOverlayState, CameraOverlayAction>
	let onTakePhoto: () -> Void
	var body: some View {
		WithViewStore (store) { viewStore in
			ZStack {
				StencilOverlay(store: self.store.scope(
					state: { $0.stencilOverlay }).actionless
				)
					.padding(128)
					.zIndex(1)
				TopButtons(store: self.store.scope(
					state: { $0.isFlashOn })
				)
					.exploding(.top)
				RightSideButtons(onTakePhoto: self.onTakePhoto,
												 store: self.store.scope(
													state: {
														$0.isShowingStencils
												}
					)
				)
					.exploding(.trailing)
				if viewStore.state.isShowingStencils {
					StencilsCollection(store:
						self.store.scope(
							state: { $0.stencilsState },
							action: { .stencils($0)}
						)
					)
						.exploding(.bottom)
				}
			}
			.buttonStyle(CameraButtonStyle())
		}
	}
}

private struct TopButtons: View {
	let store: Store<Bool, CameraOverlayAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Button.init(action: {
					viewStore.send(.closeCamera)
				}, label: {
					Image(systemName: "xmark")
				})
				Spacer()
//				Button.init(action: { }, label: {
//					Text("Edit")
//				})
				Button.init(action: {
					viewStore.send(.toggleFrontRearCamera)
				}, label: {
					Image(systemName: "camera")
				})
				Button.init(action: {
					viewStore.send(.onToggleFlash)
				}, label: {
					Image(systemName: "bolt")
				})
			}.padding()
		}
	}
}

private struct RightSideButtons: View {
	let onTakePhoto: () -> Void
	let store: Store<Bool, CameraOverlayAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 16) {
				Button.init(action: {
					viewStore.send(.onToggleStencils)
				}, label: {
					Image(systemName: "wand.and.stars")
						.foregroundColor(viewStore.state ? .white : Color.cameraImages)
				})
				Button.init(action: self.onTakePhoto, label: {
					Image("ico-journey-upload-photos-take-a-photo")
					.resizable()
					.frame(width: 54, height: 54)
				})
			}.padding()
		}
	}
}

struct CameraButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: 22))
			.frame(width: 50, height: 50)
			.foregroundColor(Color.white)
			.background(Color.black.opacity(0.2))
			.clipShape(Circle())
	}
}

extension CameraOverlayState {
	var stencilsState: StencilsState {
		get {
			StencilsState(stencils: self.stencils,
										selectedStencilIdx: self.selectedStencilIdx)
		}
		set {
			self.stencils = newValue.stencils
			self.selectedStencilIdx = newValue.selectedStencilIdx
		}
	}
}

extension CameraOverlayState {
	var stencilOverlay: StencilOverlayState {
		get {
			StencilOverlayState(stencils: self.stencils,
													selectedStencilIdx: self.selectedStencilIdx,
													isShowingStencils: self.isShowingStencils)
		}
		set {
			self.stencils = newValue.stencils
			self.selectedStencilIdx = newValue.selectedStencilIdx
			self.isShowingStencils = newValue.isShowingStencils
		}
	}
}

extension UIImagePickerController.CameraDevice {
	mutating func toggle() {
		self = self == .rear ? .front : .rear
	}
}
