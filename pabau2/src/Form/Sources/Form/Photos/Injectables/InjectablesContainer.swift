import SwiftUI
import ComposableArchitecture

public struct InjectablesState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: IdentifiedArrayOf<Injection>]
	var isChooseInjectablesActive: Bool
	var chosenInjectableId: InjectableId?
	var chosenInjectionId: UUID?
}

public enum InjectablesAction: Equatable {
	case injectablesTool(InjectablesToolAction)
	case canvas(InjectablesCanvasAction)
	case chooseInjectables(ChooseInjectableAction)
}

public let injectablesContainerReducer: Reducer<InjectablesState, InjectablesAction, FormEnvironment> = .combine(
	injectablesToolReducer.optional.pullback(
		state: \InjectablesState.injectablesTool,
		action: /InjectablesAction.injectablesTool,
		environment: { $0 }),
	injectablesCanvasReducer.optional.pullback(
		state: \InjectablesState.canvas,
		action: /InjectablesAction.canvas,
		environment: { $0 }),
	chooseInjectableReducer.pullback(
		state: \InjectablesState.chooseInjectables,
		action: /InjectablesAction.chooseInjectables,
		environment: { $0 })
)

//struct InjectablesContainer: View {
//	let store: Store<InjectablesState, InjectablesAction>
//	@Binding var photoSize: CGSize
//	let footerHeight: CGFloat
//
//	init(store: Store<InjectablesState, InjectablesAction>,
//			 photoSize: Binding<CGSize>,
//			 footerHeight: CGFloat
//	) {
//		self.store = store
//		self._photoSize = photoSize
//		self.footerHeight = footerHeight
//	}
//
//	struct ViewState: Equatable {
//		let isChooseInjectablesActive: Bool
//		let chosenInjectableId: InjectableId?
//	}
//
//	var body: some View {
//		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
//			VStack {
//				IfLetStore(self.store.scope(
//					state: { $0.canvas },
//					action: { .canvas($0)})
//					, then: {
//						InjectablesCanvas(size: self.photoSize, store: $0)
//							.frame(width: self.photoSize.width,
//										 height: self.photoSize.height)
//				})
//				Spacer()
//				IfLetStore(self.store.scope(
//					state: { $0.stepper },
//					action: { .stepper($0)})
//					, then: {
//						InjectableStepper(store: $0)
//							.frame(height: self.footerHeight)
//				})
//			}.sheet(isPresented: viewStore.binding(
//				get: { $0.isChooseInjectablesActive },
//				send: { _ in .chooseInjectables(.onDismissChooseInjectables) }
//				), content: {
//					ChooseInjectable(store:
//						self.store.scope(state: { $0.chooseInjectables },
//														 action: { .chooseInjectables($0) })
//					)
//			})
//		}
//	}
//}
//
//extension InjectablesContainer.ViewState {
//	init(state: InjectablesState) {
//		self.isChooseInjectablesActive = state.isChooseInjectablesActive
//		self.chosenInjectableId = state.chosenInjectableId
//	}
//}

extension InjectablesState {

	var injectablesTool: InjectablesToolState? {
		get {
			chosenInjectableId.map { chosenInjectableId in
				return InjectablesToolState(
					allInjectables: self.allInjectables,
					photoInjections: self.photoInjections,
					chosenInjectableId: chosenInjectableId,
					chosenInjectionId: self.chosenInjectionId
				)
			}
		}
		set {
			newValue.map {
				self.allInjectables = $0.allInjectables
				self.photoInjections = $0.photoInjections
				self.chosenInjectableId = $0.chosenInjectableId
				self.chosenInjectionId = $0.chosenInjectionId
			}
		}
	}

	var canvas: InjectablesCanvasState? {
		get {
			chosenInjectableId.map { chosenInjectableId in
				return InjectablesCanvasState(
					allInjectables: self.allInjectables,
					photoInjections: self.photoInjections,
					chosenInjectableId: chosenInjectableId,
					chosenInjectionId: self.chosenInjectionId
				)
			}
		}
		set {
			newValue.map {
				self.allInjectables = $0.allInjectables
				self.photoInjections = $0.photoInjections
				self.chosenInjectableId = $0.chosenInjectableId
				self.chosenInjectionId = $0.chosenInjectionId
			}
		}
	}

	var chooseInjectables: ChooseInjectablesState {
		get {
			ChooseInjectablesState(
				allInjectables: self.allInjectables,
				photoInjections: self.photoInjections,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				chosenInjectableId: self.chosenInjectableId
			)
		}
		set {
			self.allInjectables = newValue.allInjectables
			self.photoInjections = newValue.photoInjections
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectableId = newValue.chosenInjectableId
		}
	}
}
