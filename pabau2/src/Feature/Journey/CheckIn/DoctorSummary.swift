import SwiftUI
import ComposableArchitecture
import Model

struct DoctorSummaryState: Equatable {
	var isChooseConsentActive: Bool
	var isChooseTreatmentActive: Bool
	var isCheckInMainActive: Bool
	var doctor: StepsState
}

let doctorSummaryReducer = Reducer <DoctorSummaryState, DoctorSummaryAction, JourneyEnvironemnt> { state, action, _ in
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
		state.isCheckInMainActive = true
	case .didTouchBackFromCheckInMain:
		state.isCheckInMainActive = false
	}
	return .none
}

public enum DoctorSummaryAction {
	case didTouchAdd(ChooseFormMode)
	case didTouchStep(Int)
	case didTouchBackFrom(ChooseFormMode)
	case didTouchBackFromCheckInMain
}

struct DoctorSummary: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, DoctorSummaryAction>
	init (store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		self.viewStore = ViewStore(store
			.scope(state: { $0 },
						 action: { .doctorSummary($0)}))
	}
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 32) {
				DoctorSummaryStepList(self.viewStore.state.doctor.stepsState) {
					self.viewStore.send(.didTouchStep($0))
				}
				AddConsentBtns {
					self.viewStore.send(.didTouchAdd($0))
				}
				Spacer()
				NavigationLink.emptyHidden(self.viewStore.state.doctorSummary.isCheckInMainActive,
																	 CheckInMain(store: self.store,
																							 journey: self.viewStore.state.journey,
																							 journeyMode: .doctor))
					.customBackButton {
						self.viewStore.send(.didTouchBackFromCheckInMain)
				}
				NavigationLink.emptyHidden(self.viewStore.state.doctorSummary.isChooseTreatmentActive,
																	 ChooseFormList(store: self.store.scope(state: {
																		$0.chooseTreatments
																	}, action: {
																		.chooseTreatments($0)
																	}),
																								mode: .treatmentNotes))
					.customBackButton {
						self.viewStore.send(.didTouchBackFrom(.treatmentNotes))
				}
			}.frame(width: geo.size.width * 0.75)
				.journeyBase(self.viewStore.state.journey, .long)
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
		self.btnTxt = mode == .consents ? "Add Consent" : "Add Treatment Not"
		self.imageName = mode == .consents ? "ico-journey-consent" : "ico-journey-treatment-notes"
		self.onSelect = action
	}

	var body: some View {
		Button.init(action: { self.onSelect(self.mode) }, label: {
			HStack {
				Image(imageName)
				Text(mode.btnTitle)
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
		ForEach(0..<self.stepsVMs.count) { idx in
			VStack(spacing: 0) {
				DoctorSummaryRow(step: self.stepsVMs[idx])
					.onTapGesture { self.onSelect(idx) }
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
