import SwiftUI
import ComposableArchitecture

public struct CameraOverlayState: Equatable {
	var photos: IdentifiedArrayOf<PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isCameraActive: Bool
	var stencils: [Stencil]
	var selectedStencilIdx: Int?
	var isShowingStencils: Bool
	var isShowingPhotoLib: Bool
}

public enum CameraOverlayAction: Equatable {
	case onToggleStencils
	case onOpenPhotosLibrary
	case didTakePhoto(UIImage)
	case closeCamera
	case stencils(StencilsAction)
}

private enum BottomCollectionType {
	case stencils
	case photos
}

let cameraOverlayReducer: Reducer<CameraOverlayState, CameraOverlayAction, JourneyEnvironment> =
	.combine(
		stencilsReducer.pullback(
			state: \CameraOverlayState.stencilsState,
			action: /CameraOverlayAction.stencils,
			environment: { $0 }),
		.init { state, action, _ in
			switch action {
			case .onOpenPhotosLibrary:
				state.isShowingPhotoLib = true
			case .didTakePhoto(let image):
				let newPhoto = NewPhoto.init(id: UUID(),
																		 image: image,
																		 date: Date())
				state.photos.insert(PhotoViewModel(newPhoto), at: state.photos.count)
				state.editingPhotoId = .new(newPhoto.id)
			case .closeCamera:
				state.isCameraActive = false
			case .onToggleStencils:
				state.isShowingStencils.toggle()
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
				TopButtons(store: self.store.stateless)
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
	let store: Store<Void, CameraOverlayAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Button.init(action: {
					viewStore.send(.closeCamera)
				}, label: {
					Image(systemName: "xmark.circle.fill")
				})
				Spacer()
				Button.init(action: { }, label: {
					Text("Edit")
				})
				Button.init(action: { }, label: {
					Image(systemName: "camera")
				})
				Button.init(action: { }, label: {
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
			VStack {
				Button.init(action: {
					viewStore.send(.onToggleStencils)
				}, label: {
					Image(systemName: "wand.and.stars")
						.accentColor(viewStore.state ? .red : .blue)
				})
				Button.init(action: self.onTakePhoto, label: {
					Image("ico-journey-upload-photos-take-a-photo")
				})
				Button.init(action: {
					viewStore.send(.onOpenPhotosLibrary)
				}, label: {
					Image(systemName: "photo.on.rectangle")
				})
			}.padding()
		}
	}
}

struct CameraButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(width: 44, height: 44)
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
