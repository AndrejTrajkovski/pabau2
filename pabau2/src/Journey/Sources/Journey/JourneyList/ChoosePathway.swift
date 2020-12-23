import SwiftUI
import Model
import Util
import ComposableArchitecture
import Form

public enum ChoosePathwayContainerAction {
	case choosePathway(ChoosePathwayAction)
	case chooseConsent(ChooseFormAction)
}

let choosePathwayContainerReducer: Reducer<ChoosePathwayState, ChoosePathwayContainerAction, JourneyEnvironment> =
	.combine(
		chooseFormListReducer.pullback(
			state: \ChoosePathwayState.chooseConsentState,
			action: /ChoosePathwayContainerAction.chooseConsent,
			environment: makeFormEnv(_:)
		),
		choosePathwayReducer.pullback(
			state: \ChoosePathwayState.self,
			action: /ChoosePathwayContainerAction.choosePathway,
			environment: { $0 })
)

let choosePathwayReducer = Reducer<ChoosePathwayState, ChoosePathwayAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didChoosePathway(let pathway):
		state.selectedPathway = pathway
	case .didTouchSelectConsentBackBtn:
		state.selectedPathway = nil
	}
	return .none
}

public enum ChoosePathwayAction {
	case didChoosePathway(PathwayTemplate)
	case didTouchSelectConsentBackBtn
}

public struct ChoosePathwayState: Equatable {
	var selectedJourney: Journey?
	var selectedPathway: PathwayTemplate?
	var selectedConsentsIds: [HTMLFormTemplate.ID]
	var allConsents: IdentifiedArrayOf<HTMLFormTemplate>
	var chooseConsentState: ChooseFormState {
		get {
			ChooseFormState(templates: allConsents,
							selectedTemplatesIds: selectedConsentsIds)
		}
		set {
			self.selectedConsentsIds = newValue.selectedTemplatesIds
			self.allConsents = newValue.templates
		}
	}
}

public struct ChoosePathway: View {
	let store: Store<ChoosePathwayState, ChoosePathwayContainerAction>
	@ObservedObject var viewStore: ViewStore<State, ChoosePathwayContainerAction>
	struct State: Equatable {
		let isChooseConsentShown: Bool
		let journey: Journey?

		let standardPathway =
			PathwayTemplate.init(id: 1,
									 title: "Standard",
									 steps: [Step(id: 1, stepType: .patientdetails),
													 Step(id: 2, stepType: .medicalhistory),
													 Step(id: 3, stepType: .consents),
													 Step(id: 4, stepType: .treatmentnotes),
													 Step(id: 5, stepType: .prescriptions),
													 Step(id: 6, stepType: .aftercares),
													 Step(id: 7, stepType: .checkpatient),
													 Step(id: 8, stepType: .photos)
			])
		let consultationPathway =
			PathwayTemplate.init(id: 1,
									 title: "Consultation",
									 steps: [Step(id: 1, stepType: .patientdetails),
													 Step(id: 2, stepType: .medicalhistory),
													 Step(id: 3, stepType: .consents),
													 Step(id: 3, stepType: .treatmentnotes),
													 Step(id: 6, stepType: .aftercares),
													 Step(id: 5, stepType: .checkpatient),
													 Step(id: 8, stepType: .photos)
				]
		)
		init(state: ChoosePathwayState) {
			self.isChooseConsentShown = state.selectedPathway != nil
			self.journey = state.selectedJourney
			UITableView.appearance().separatorStyle = .none
		}
	}

	init(store: Store<ChoosePathwayState, ChoosePathwayContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: State.init(state:),
						 action: { $0 }))
	}
	public var body: some View {
		HStack {
			pathwayCells
			chooseFormNavLink
		}
		.journeyBase(self.viewStore.state.journey, .long)
	}

	var chooseFormNavLink: some View {
		NavigationLink.emptyHidden(self.viewStore.state.isChooseConsentShown,
															 ChooseFormList(store:
																self.store.scope(
																	state: { $0.chooseConsentState },
																	action: { .chooseConsent($0)}),
																	mode: .consentsPreCheckIn)
																.journeyBase(self.viewStore.state.journey, .long)
																.customBackButton {
																	self.viewStore.send(.choosePathway(.didTouchSelectConsentBackBtn))
			}
		)
	}

	var pathwayCells: some View {
		HStack {
			ListFrame(style: .blue) {
				ChoosePathwayListContent(
					.blue,
					Image(systemName: "arrow.right"),
					self.viewStore.state.standardPathway.steps.count,
					"Standard Pathway",
					"Provides a basic standard pathway, defined for the company.",
					self.viewStore.state.standardPathway.steps.map { $0.stepType.title },
					"Standard") {
						self.viewStore.send(.choosePathway(.didChoosePathway(self.viewStore.state.standardPathway)))
				}
			}
			ListFrame(style: .white) {
				ChoosePathwayListContent(
					.white,
					Image("ico-journey-consulting"),
					self.viewStore.state.consultationPathway.steps.count,
					"Consultation Pathway",
					"Provides a consultation pathway, to hear out the person's needs.",
					self.viewStore.state.consultationPathway.steps.map { $0.stepType.title },
					"Consultation") {
						self.viewStore.send(.choosePathway(.didChoosePathway(self.viewStore.state.consultationPathway)))
				}
			}
		}
	}
}

struct ChoosePathwayListContent: View {
	let bottomLeading: Image
	let numberOfSteps: Int
	let title: String
	let subtitle: String
	let bulletPoints: [String]
	let btnTxt: String
	let style: ListFrameStyle
	let btnAction: () -> Void

	init(
		_ style: ListFrameStyle,
		_ bottomLeading: Image,
		_ numberOfSteps: Int,
		_ title: String,
		_ subtitle: String,
		_ bulletPoints: [String],
		_ btnTxt: String,
		_ btnAction: @escaping () -> Void) {
		self.bottomLeading = bottomLeading
		self.numberOfSteps = numberOfSteps
		self.title = title
		self.subtitle = subtitle
		self.bulletPoints = bulletPoints
		self.btnTxt = btnTxt
		self.btnAction = btnAction
		self.style = style
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			PathwayCellHeader(bottomLeading, numberOfSteps)
			Text(title).font(.semibold20).foregroundColor(.black42)
			Text(subtitle).font(.medium15)
			PathwayBulletList(bulletPoints: bulletPoints, bgColor: style.bgColor)
			Spacer()
			if style == .blue {
				PrimaryButton(btnTxt, btnAction)
			} else {
				SecondaryButton(btnTxt, btnAction)
			}
		}
	}
}

struct PathwayBulletList: View {
	let bulletPoints: [String]
	let bgColor: Color
	var body: some View {
		List {
			ForEach(bulletPoints, id: \.self) { bulletPoint in
				HStack {
					Circle()
						.fill(Color.grey216)
						.frame(width: 6.6, height: 6.6)
					Text(bulletPoint)
						.font(.regular16)
				}
				.listRowInsets(EdgeInsets())
				.listRowBackground(self.bgColor)
			}
		}
	}
}

struct PathwayCellHeader: View {
	let image: Image
	let numberOfSteps: Int
	init(_ image: Image, _ numberOfSteps: Int) {
		self.image = image
		self.numberOfSteps = numberOfSteps
	}
	var body: some View {
		ZStack {
			image.font(Font.regular45).foregroundColor(.blue2)
				.frame(minWidth: 0, maxWidth: .infinity,
							 minHeight: 0, maxHeight: .infinity,
							 alignment: .leading)
			Spacer()
			HStack {
				Image(systemName: "list.bullet").foregroundColor(.blue2)
				Text(String("\(numberOfSteps)")).font(.semibold17)
			}.frame(minWidth: 0, maxWidth: .infinity,
							minHeight: 0, maxHeight: .infinity,
							alignment: .topTrailing)
		}
		.frame(height: 54)
	}
}
