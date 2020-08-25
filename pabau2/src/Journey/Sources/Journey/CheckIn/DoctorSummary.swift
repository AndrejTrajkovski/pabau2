import SwiftUI
import ComposableArchitecture
import Model
import Overture
import Util
import Form

struct DoctorSummaryState: Equatable {
	let journey: Journey
	var isChooseConsentActive: Bool
	var isChooseTreatmentActive: Bool
	var isDoctorCheckInMainActive: Bool
	var doctorCheckIn: CheckInViewState
}

let doctorSummaryReducer = Reducer <DoctorSummaryState, DoctorSummaryAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didTouchBackFrom(let mode):
		switch mode {
		case .consentsCheckIn:
			state.isChooseConsentActive = false
		case .treatmentNotes:
			state.isChooseTreatmentActive = false
		case .consentsPreCheckIn:
			fatalError("should be handled pre checkin")
		}
	case .didTouchAdd(let mode):
		switch mode {
		case .consentsCheckIn:
			state.isChooseConsentActive = true
		case .treatmentNotes:
			state.isChooseTreatmentActive = true
		case .consentsPreCheckIn:
			fatalError("should be handled pre checkin")
		}
	case .didTouchStep(let stepType):
		state.doctorCheckIn.forms.selectedStep = stepType
		state.isDoctorCheckInMainActive = true
	case .xOnDoctorCheckIn:
		break //handled in checkInMiddleware
	}
	return .none
}

public enum DoctorSummaryAction {
	case didTouchAdd(ChooseFormMode)
	case didTouchStep(StepType)
	case didTouchBackFrom(ChooseFormMode)
	case xOnDoctorCheckIn
}

struct DoctorNavigation: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, DoctorSummaryAction>
	init (_ store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: { State.init($0.doctorSummary) },
			action: { .doctorSummary($0) }))
	}
	struct State: Equatable {
		let isDoctorCheckInMainActive: Bool
		let isChooseTreatmentActive: Bool
		let isChooseConsentActive: Bool
		let journey: Journey
	}

	var body: some View {
		print("DoctorNavigation body")
		return VStack {
			NavigationLink.emptyHidden(viewStore.state.isDoctorCheckInMainActive,
																 CheckInMain(store: self.store
																	.scope(state: { $0.doctorCheckIn },
																				 action: { .doctor($0) }))
			)
			NavigationLink.emptyHidden(viewStore.state.isChooseConsentActive,
																 ChooseFormJourney(store: self.store.scope(
																	state: { $0.chooseConsents },
																	action: { .chooseConsents($0)}),
																									mode: .consentsCheckIn,
																									journey: self.viewStore.state.journey)
																	.customBackButton {
																		self.viewStore.send(.didTouchBackFrom(.consentsCheckIn))
				}
			)
			NavigationLink.emptyHidden(viewStore.state.isChooseTreatmentActive,
																 ChooseFormJourney(store: self.store.scope(
																	state: { $0.chooseTreatments },
																	action: { .chooseTreatments($0)}),
																									mode: .treatmentNotes,
																									journey: self.viewStore.state.journey)
																	.customBackButton {
																		self.viewStore.send(.didTouchBackFrom(.treatmentNotes))
				}
			)
		}
	}
}

extension DoctorNavigation.State {
  init(_ state: DoctorSummaryState) {
		self.isChooseConsentActive = state.isChooseConsentActive
		self.isChooseTreatmentActive = state.isChooseTreatmentActive
		self.isDoctorCheckInMainActive = state.isDoctorCheckInMainActive
		self.journey = state.journey
	}
}

struct DoctorSummaryStepList: View {
	let onSelect: (StepState) -> Void
	let stepsVMs: [StepState]
	init (_ stepsVMs: [StepState], _ onSelect: @escaping (StepState) -> Void) {
		self.stepsVMs = stepsVMs
		self.onSelect = onSelect
	}

	var body: some View {
		VStack(spacing: 0) {
			ForEach(self.stepsVMs, id: \.stepType) { step in
				VStack(spacing: 0) {
					DoctorSummaryRow(step: step)
						.onTapGesture { self.onSelect(step) }
						.frame(height: 59)
					Divider()
				}.padding(0)
			}
		}
	}
}

struct DoctorSummaryRow: View {
	let step: StepState
	var body: some View {
		HStack {
			Text(step.stepType.title).font(.semibold17)
			Spacer()
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(step.isComplete ? .blue : .lightBlueGrey)
				.frame(width: 30, height: 30)
			Image(systemName: "chevron.right")
				.foregroundColor(.arrowGray)
				.frame(width: 8, height: 13)
		}
	}
}

struct StepState: Equatable {
	var stepType: StepType
	var isComplete: Bool
}

extension DoctorSummaryState {
	var steps: [StepState] {
		return doctorCheckIn.forms.forms.map {
			StepState.init(stepType: $0.stepType, isComplete: $0.isComplete)
		}
//		return Dictionary.init(grouping: doctorCheckIn.forms,
//															 by: pipe(get(\.form), stepType(form:)))
//			.reduce(into: [StepState](), {
//				$0.append(
//					StepState(stepType: $1.key,
//										isComplete: $1.value.allSatisfy(\.isComplete))
//				)
//			})
//			.sorted(by: their(get(\.stepType.order)))
	}
}

struct NavBarHidden: ViewModifier {
	let isNavBarHidden: Bool
	let title: String
	func body(content: Content) -> some View {
		content
			.navigationBarTitle(isNavBarHidden ? Text("") : Text(title), displayMode: .inline)
			.navigationBarHidden(isNavBarHidden)
			.navigationBarBackButtonHidden(isNavBarHidden)
	}
}

extension View {
	func hideNavBar(_ isNavBarHidden: Bool, _ title: String = "") -> some View {
		self.modifier(NavBarHidden(isNavBarHidden: isNavBarHidden, title: title))
	}
}

//func calcFormsSelectedIndex(stepType: StepType,
//														forms: IdentifiedArrayOf<MetaFormAndStatus>) -> Int? {
//	let selectedType = steps[selectedStepIdx]
//	let grouped = Dictionary.init(grouping: forms,
//																by: pipe(get(\.form), stepType(form:)))
//	guard let formsForSelectedStep = grouped[selectedType.stepType] else { return nil}
//	let selForm = { () -> MetaFormAndStatus? in
//		if let notCompleteForm = formsForSelectedStep.first(where: { !$0.isComplete}) {
//			return notCompleteForm
//		} else {
//			return formsForSelectedStep.first
//		}
//	}()
//	return forms.firstIndex(where: { $0 == selForm })
//}
