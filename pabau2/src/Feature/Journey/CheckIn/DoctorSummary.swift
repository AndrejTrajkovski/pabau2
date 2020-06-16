import SwiftUI
import ComposableArchitecture
import Model
import Overture
import Util

struct DoctorSummaryState: Equatable {
	var journey: Journey
	var isChooseConsentActive: Bool
	var isChooseTreatmentActive: Bool
	var isDoctorCheckInMainActive: Bool
	var doctorCheckIn: CheckInViewState
}

func calcFormsSelectedIndex(steps: [StepState],
														selectedStepIdx: Int,
														forms: [MetaFormAndStatus]) -> Int? {
	let selectedType = steps[selectedStepIdx]
	let grouped = Dictionary.init(grouping: forms,
																by: pipe(get(\.form), stepType(form:)))
	guard let formsForSelectedStep = grouped[selectedType.stepType] else { return nil}
	let selForm = { () -> MetaFormAndStatus? in
		if let notCompleteForm = formsForSelectedStep.first(where: { !$0.isComplete}) {
			return notCompleteForm
		} else {
			return formsForSelectedStep.first
		}
	}()
	return forms.firstIndex(where: { $0 == selForm })
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
	case .didTouchStep(let idx):
		calcFormsSelectedIndex(steps: state.steps, selectedStepIdx: idx, forms: state.doctorCheckIn.forms).map {
			state.doctorCheckIn.selectedIndex = $0
		}
		state.isDoctorCheckInMainActive = true
	case .xOnDoctorCheckIn:
		break //handled in checkInMiddleware
	}
	return .none
}

public enum DoctorSummaryAction {
	case didTouchAdd(ChooseFormMode)
	case didTouchStep(Int)
	case didTouchBackFrom(ChooseFormMode)
	case xOnDoctorCheckIn
}

struct DoctorNavigation: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(
			state: { $0.doctorSummary },
			action: { .doctorSummary($0)})) { viewStore in
				VStack {
					NavigationLink.emptyHidden(viewStore.state.isDoctorCheckInMainActive,
							CheckInMain(store: self.store
								.scope(state: { $0.doctorCheckIn },
											 action: { .doctor($0) }))
					)
					NavigationLink.emptyHidden(viewStore.state.isChooseTreatmentActive,
						 ChooseFormList(store: self.store.scope(
							state: { $0.chooseTreatments },
							action: { .chooseTreatments($0)}),
							mode: .treatmentNotes)
							.customBackButton {
								viewStore.send(.didTouchBackFrom(.treatmentNotes))
							}
					)
					NavigationLink.emptyHidden(viewStore.state.isChooseConsentActive,
						 ChooseFormList(store: self.store.scope(
							state: { $0.chooseConsents },
							action: { .chooseConsents($0)}),
							mode: .consentsCheckIn)
							.customBackButton {
								viewStore.send(.didTouchBackFrom(.consentsCheckIn))
							}
					)
			}
		}
	}
}

struct DoctorSummaryStepList: View {
	let onSelect: (Int) -> Void
	let stepsVMs: [StepState]
	init (_ stepsVMs: [StepState], _ onSelect: @escaping (Int) -> Void) {
		self.stepsVMs = stepsVMs
		self.onSelect = onSelect
	}

	var body: some View {
		VStack(spacing: 0) {
			ForEach(self.stepsVMs, id: \.stepType) { step in
				VStack(spacing: 0) {
					DoctorSummaryRow(step: step)
						.onTapGesture { self.onSelect(self.stepsVMs.firstIndex(of: step)!) }
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
		return Dictionary.init(grouping: doctorCheckIn.forms,
															 by: pipe(get(\.form), stepType(form:)))
			.reduce(into: [StepState](), {
				$0.append(
					StepState(stepType: $1.key,
										isComplete: $1.value.allSatisfy(\.isComplete))
				)
			})
			.sorted(by: their(get(\.stepType.order)))
	}
}
