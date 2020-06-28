import SwiftUI
import ComposableArchitecture

public struct InjectablesState: Equatable {
	var allInjectables: [Injectable]
	var photoInjections: IdentifiedArrayOf<InjectionsAndActive>
	var isChooseInjectablesActive: Bool
	var stepper: InjectableStepperState?
	var canvas: InjectablesCanvasState?
	
	var chooseInjectables: ChooseInjectablesState {
		get {
			ChooseInjectablesState(
				allInjectables: self.allInjectables,
				photoInjections: self.photoInjections,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				stepper: self.stepper,
				canvas: self.canvas
			)
		}
		set {
			self.allInjectables = newValue.allInjectables
			self.photoInjections = newValue.photoInjections
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.stepper = newValue.stepper
			self.canvas = newValue.canvas
		}
	}
}

public enum InjectablesAction: Equatable {
	case stepper(InjectableStepperAction)
	case canvas(InjectablesCanvasAction)
	case chooseInjectables(ChooseInjectableAction)
}

public let injectablesContainerReducer: Reducer<InjectablesState, InjectablesAction, JourneyEnvironment> = .combine(
	injectableStepperReducer.optional.pullback(
		state: \InjectablesState.stepper,
		action: /InjectablesAction.stepper,
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

struct InjectablesContainer: View {
	let store: Store<InjectablesState, InjectablesAction>
	@Binding var photoSize: CGSize
	let footerHeight: CGFloat
	
	init(store: Store<InjectablesState, InjectablesAction>,
			 photoSize: Binding<CGSize>,
			 footerHeight: CGFloat
			 ) {
		self.store = store
		self._photoSize = photoSize
		self.footerHeight = footerHeight
	}
	
	struct ViewState: Equatable {
		let isChooseInjectablesActive: Bool
	}
	
	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			VStack {
				IfLetStore(self.store.scope(
					state: { $0.canvas },
					action: { .canvas($0)})
					, then: {
						InjectablesCanvas(size: self.photoSize, store: $0)
							.frame(width: self.photoSize.width,
										 height: self.photoSize.height)
				})
				IfLetStore(self.store.scope(
					state: { $0.stepper },
					action: { .stepper($0)})
					, then: {
						InjectableStepper(store: $0)
				})
					.frame(height: self.footerHeight)
			}.sheet(isPresented: .constant(viewStore.state.isChooseInjectablesActive),
						 content: {
							ChooseInjectable(store:
								self.store.scope(state: { $0.chooseInjectables },
																 action: { .chooseInjectables($0) })
							)
			})
		}
	}
}

extension InjectablesContainer.ViewState {
	init(state: InjectablesState) {
		self.isChooseInjectablesActive = state.isChooseInjectablesActive
	}
}
