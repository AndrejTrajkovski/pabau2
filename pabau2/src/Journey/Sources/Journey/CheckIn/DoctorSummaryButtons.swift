import SwiftUI
import ComposableArchitecture
import Util
import Model
import Form

struct DoctorSummary: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, DoctorSummaryAction>

	struct State: Equatable {
		let steps: [StepState]
		let journey: Journey
	}

	init (store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store
			.scope(state: State.init(state:),
						 action: { .doctorSummary($0)}
			)
		)
	}
	var body: some View {
		print("DoctorSummary body")
		return GeometryReader { geo in
			VStack(spacing: 32) {
				DoctorSummaryStepList(self.viewStore.state.steps) {
					self.viewStore.send(.didTouchStep($0))
				}
				DoctorSummaryButtons(store:
					self.store.scope(
						state: { $0.doctorArray }, action: { $0 })
				)
				Spacer()
				DoctorNavigation(self.store.scope(state: { $0 }, action: { $0 }))
			}
			.frame(width: geo.size.width * 0.75)
			.journeyBase(self.viewStore.state.journey, .long)
			.navigationBarItems(leading:
				XButton(onTap: { self.viewStore.send(.xOnDoctorCheckIn)}))
		}
	}
}

struct DoctorSummaryButtons: View {
	let store: Store<[MetaFormAndStatus], CheckInContainerAction>
	@State var btnWidth: CGFloat = 0
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 24) {
				AddConsentBtns {
					viewStore.send(.doctorSummary(.didTouchAdd($0)))
				}
				DoctorSummaryCompleteBtn(
					store: self.store.scope(state: { $0 },
																	action: { $0 })
				).frame(width: self.btnWidth)
			}.onPreferenceChange(WidthPreferenceKey.self, perform: { self.btnWidth = $0 })
		}
	}
}

struct WidthPreferenceKey: PreferenceKey {
	static var defaultValue = CGFloat(0)
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
	typealias Value = CGFloat
}

struct BtnGeometry: View {
	var body: some View {
		GeometryReader { geometry in
			return Rectangle().fill(Color.clear).preference(key: WidthPreferenceKey.self, value: geometry.size.width)
		}
	}
}

struct AddConsentBtns: View {
	let onSelect: (ChooseFormMode) -> Void
	var body: some View {
		HStack {
			AddFormButton(mode: .consentsCheckIn, action: onSelect)
				.background(BtnGeometry())
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
		self.btnTxt = mode == .treatmentNotes ? Texts.addTreatment : Texts.addConsent
		self.imageName = mode == .treatmentNotes ? "ico-journey-treatment-notes": "ico-journey-consent"
		self.onSelect = action
	}

	var body: some View {
		Button.init(action: { self.onSelect(self.mode) }, label: {
			HStack {
				Image(imageName)
				Text(btnTxt)
					.font(Font.system(size: 16.0, weight: .regular))
			}.frame(minWidth: 0, maxWidth: .infinity)
		}).buttonStyle(PathwayWhiteButtonStyle())
			.shadow(color: .bigBtnShadow2,
							radius: 8.0,
							y: 4)
			.background(Color.white)
	}
}

extension DoctorSummary.State {
	init(state: CheckInContainerState) {
		self.journey = state.journey
		self.steps = state.doctorSummary.steps
	}
}
