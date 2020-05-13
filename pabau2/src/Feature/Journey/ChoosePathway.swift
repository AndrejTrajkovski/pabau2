import SwiftUI
import Model
import Util
import ComposableArchitecture


public enum ChoosePathwayContainerAction {
	case choosePathway(ChoosePathwayAction)
	case chooseConsent(ChooseFormAction)
}

let choosePathwayContainerReducer: Reducer<ChoosePathwayState, ChoosePathwayContainerAction, JourneyEnvironemnt> =
	.combine(
		chooseFormListReducer.pullback(
			state: \ChoosePathwayState.chooseConsentState,
			action: /ChoosePathwayContainerAction.chooseConsent,
			environment: { $0 })
		,
		choosePathwayReducer.pullback(
			state: \ChoosePathwayState.self,
			action: /ChoosePathwayContainerAction.choosePathway,
			environment: { $0 })
)

let choosePathwayReducer = Reducer<ChoosePathwayState, ChoosePathwayAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didChoosePathway(let pathway):
		state.selectedPathway = pathway
	case .didTouchSelectConsentBackBtn:
		state.selectedPathway = nil
	}
	return .none
}

public enum ChoosePathwayAction {
	case didChoosePathway(Pathway)
	case didTouchSelectConsentBackBtn
}

public struct ChoosePathwayState: Equatable {
	var selectedJourney: Journey?
	var selectedPathway: Pathway?
	var selectedConsentsIds: [Int]
	var allConsents: [Int: FormTemplate]
	var chooseConsentState: ChooseFormState {
		get {
			ChooseFormState(selectedJourney: selectedJourney,
											selectedPathway: selectedPathway,
											selectedTemplatesIds: selectedConsentsIds,
											templates: allConsents)
		}
		set {
			self.selectedJourney = newValue.selectedJourney
			self.selectedPathway = newValue.selectedPathway
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
			Pathway.init(id: 1,
									 title: "Standard",
									 steps: [Step(id: 1, stepType: .checkpatient),
													 Step(id: 2, stepType: .medicalhistory),
													 Step(id: 3, stepType: .consents),
													 Step(id: 4, stepType: .treatmentnotes),
													 Step(id: 5, stepType: .prescriptions),
													 Step(id: 6, stepType: .aftercares)
			])
		let consultationPathway =
			Pathway.init(id: 1,
									 title: "Consultation",
									 steps: [Step(id: 1, stepType: .checkpatient),
													 Step(id: 2, stepType: .medicalhistory),
													 Step(id: 3, stepType: .consents),
													 Step(id: 6, stepType: .aftercares)])
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
		print("ChoosePathway init")
	}
	public var body: some View {
		print("ChoosePathway body")
		return HStack {
			self.pathwayCells
			self.chooseFormNavLink
		}
		.journeyBase(self.viewStore.state.journey, .long)
	}

	var chooseFormNavLink: some View {
		NavigationLink.emptyHidden(self.viewStore.state.isChooseConsentShown,
															 ChooseFormList(store: self.store.scope(
																	state: { $0.chooseConsentState },
																	action: { .chooseConsent($0)}), mode: .consents)
																.navigationBarTitle("Choose Consent")
																.customBackButton {
																	self.viewStore.send(.choosePathway(.didTouchSelectConsentBackBtn))
			}
		)
	}

	var pathwayCells: some View {
		HStack {
			PathwayCell(style: .blue) {
				ChoosePathwayListContent.init(.blue,
																			Image(systemName: "arrow.right"),
																			self.viewStore.state.standardPathway.steps.count,
																			"Standard Pathway",
																			"Provides a basic standard pathway, defined for the company.",
																			self.viewStore.state.standardPathway.steps.map { $0.stepType.title },
																			"Standard") {
																				self.viewStore.send(.choosePathway(.didChoosePathway(self.viewStore.state.standardPathway)))
				}
			}
			PathwayCell(style: .white) {
				ChoosePathwayListContent.init(.white,
																			Image("ico-journey-consulting"),
																			self.viewStore.state.standardPathway.steps.count,
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

enum PathwayCellStyle {
	case blue
	case white
	var bgColor: Color {
		switch self {
		case .blue:
			return .gray249
		case .white:
			return .white
		}
	}

	var btnColor: Color {
		switch self {
		case .blue:
			return .blue2
		case .white:
			return .white
		}
	}

	var btnShadowColor: Color {
		switch self {
		case .blue:
			return .bigBtnShadow1
		case .white:
			return .bigBtnShadow2
		}
	}

	var btnShadowBlur: CGFloat {
		switch self {
		case .blue:
			return 4.0
		case .white:
			return 8.0
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
	let style: PathwayCellStyle
	let btnAction: () -> Void

	init(
		_ style: PathwayCellStyle,
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
			ChoosePathwayButton(btnTxt: btnTxt, style: style, action: btnAction)
		}
	}
}

struct PathwayCell<Content: View>: View {
	init(style: PathwayCellStyle,
			 @ViewBuilder _ content: @escaping () -> Content) {
		self.style = style
		self.content = content
	}

	let style: PathwayCellStyle
	let content: () -> Content

	public var body: some View {
		VStack(spacing: 0) {
			Rectangle().fill(style.btnColor).frame(height: 8)
			content()
				.padding(32)
				.background(style.bgColor)
		}
	}
}

struct ChoosePathwayButton: View {
	let btnTxt: String
	let style: PathwayCellStyle
	let action: () -> Void
	var body: some View {
		Group {
			if self.style == .blue {
				BigButton.init(text: btnTxt,
											 btnTapAction: action)
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			} else {
				Button.init(action: action, label: {
					Text(btnTxt)
						.font(Font.system(size: 16.0, weight: .bold))
						.frame(minWidth: 0, maxWidth: .infinity)
				}).buttonStyle(PathwayWhiteButtonStyle())
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			}
		}
	}
}

struct PathwayWhiteButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.black)
			.background(Color.white)
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
