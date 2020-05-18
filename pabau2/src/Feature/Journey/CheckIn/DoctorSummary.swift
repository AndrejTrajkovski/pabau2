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

let doctorSummaryReducer = Reducer <DoctorSummaryState, DoctorSummaryAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didTouchBackFrom(let mode):
		switch mode {
		case .consents:
			state.isChooseConsentActive = false
		case .treatmentNotes:
			state.isChooseTreatmentActive = false
		}
	case .didTouchAdd(let mode):
		switch mode {
		case .consents:
			state.isChooseConsentActive = true
		case .treatmentNotes:
			state.isChooseTreatmentActive = true
		}
	case .didTouchStep(let idx):
		state.isDoctorCheckInMainActive = true
	case .backOnDoctorCheckIn:
		state.isDoctorCheckInMainActive = false
	}
	return .none
}

public enum DoctorSummaryAction {
	case didTouchAdd(ChooseFormMode)
	case didTouchStep(Int)
	case didTouchBackFrom(ChooseFormMode)
	case backOnDoctorCheckIn
}

struct DoctorSummary: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<DoctorSummaryState, DoctorSummaryAction>
	init (store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store
			.scope(state: { $0.doctorSummary },
						 action: { .doctorSummary($0)}))
	}
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 32) {
				DoctorSummaryStepList(self.viewStore.state.steps) {
					self.viewStore.send(.didTouchStep($0))
				}
				AddConsentBtns {
					self.viewStore.send(.didTouchAdd($0))
				}
				Spacer()
				DoctorNavigation(store: self.store)
			}.frame(width: geo.size.width * 0.75)
				.journeyBase(self.viewStore.state.journey, .long)
		}
	}
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
							.navigationBarHidden(true)
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
							mode: .consents)
							.customBackButton {
								viewStore.send(.didTouchBackFrom(.consents))
							}
					)
			}
		}
	}
}

struct AddConsentBtns: View {
	let onSelect: (ChooseFormMode) -> Void
	var body: some View {
		HStack {
			AddFormButton(mode: .consents, action: onSelect)
			AddFormButton(mode: .treatmentNotes, action: onSelect)
		}
	}
}

struct AddFormButton: View {
	let mode: ChooseFormMode
	let btnTxt: String
	let imageName: String
	let onSelect: (ChooseFormMode) -> Void

	init(mode: ChooseFormMode, action: @escaping (ChooseFormMode) -> Void) {
		self.mode = mode
		self.btnTxt = mode == .consents ? "Add Consent" : "Add Treatment Note"
		self.imageName = mode == .consents ? "ico-journey-consent" : "ico-journey-treatment-notes"
		self.onSelect = action
	}

	var body: some View {
		Button.init(action: { self.onSelect(self.mode) }, label: {
			HStack {
				Image(imageName)
				Text(btnTxt)
					.font(Font.system(size: 16.0, weight: .bold))
					.frame(minWidth: 0, maxWidth: .infinity)
			}
		}).buttonStyle(PathwayWhiteButtonStyle())
			.shadow(color: .bigBtnShadow2,
							radius: 8.0,
							y: 2)
			.background(Color.white)
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
		ForEach(self.stepsVMs, id: \.stepType) { step in
			VStack(spacing: 0) {
				DoctorSummaryRow(step: step)
					.onTapGesture { self.onSelect(self.stepsVMs.firstIndex(of: step)!) }
				Divider()
			}
		}
	}
}

struct DoctorSummaryRow: View {
	let step: StepState
	var body: some View {
		VStack {
			HStack {
				Text(step.stepType.title).font(.semibold17)
				Spacer()
				Image(systemName: "checkmark.circle.fill")
					.foregroundColor(step.isComplete ? .blue : .gray)
					.frame(width: 30, height: 30)
				Image(systemName: "chevron.right")
					.frame(width: 8, height: 13)
			}
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
