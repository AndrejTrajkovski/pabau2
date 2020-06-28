import SwiftUI
import ComposableArchitecture

public struct InjectablesState: Equatable {
	var allInjectables: [Injectable]
	var photoInjections: IdentifiedArrayOf<InjectionsAndActive>
	var chosenIncrement: Double
	var chosenInjectable: Injectable?
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
	case chooseInjectable(ChooseInjectableAction)
}

public let injectableCanvasReducer: Reducer<InjectablesState, InjectablesAction, JourneyEnvironment> = .combine(
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
		action: /InjectablesAction.chooseInjectable,
		environment: { $0 })
)
