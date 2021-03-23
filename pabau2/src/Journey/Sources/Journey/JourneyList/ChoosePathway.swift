import SwiftUI
import Model
import Util
import ComposableArchitecture
import Form
import Overture
import Combine

public enum ChoosePathwayContainerAction {
	case rows(id: PathwayTemplate.ID, action: PathwayTemplateRowAction)
	case choosePathway(ChoosePathwayAction)
	case chooseConsent(ChooseFormAction)
	case checkIn(CheckInContainerAction)
	case gotPathwayTemplates(Result<IdentifiedArrayOf<PathwayTemplate>, RequestError>)
}

let choosePathwayContainerReducer: Reducer<ChoosePathwayState, ChoosePathwayContainerAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, _ in
			switch action {
			case .chooseConsent(.proceed):
				state.checkIn = CheckInContainerState(journey: state.selectedJourney,
													  pathway: state.selectedPathway!,
													  patientDetails: ClientBuilder.empty,
													  medicalHistoryId: HTMLForm.getMedHistory().id,
													  medHistory: HTMLFormParentState.init(info: FormTemplateInfo(id: HTMLForm.getMedHistory().id, name: "MEDICAL HISTORY", type: .history), clientId: Client.ID.init(rawValue: .right(1)), getLoadingState: .initial),
													  consents: state.allConsents.filter(
														pipe(get(\.id), state.selectedConsentsIds.contains)
													  ),
													  allConsents: state.allConsents,
													  photosState: PhotosState.init(SavedPhoto.mock())
				)
				return Just(ChoosePathwayContainerAction.checkIn(CheckInContainerAction.showPatientMode))
					.delay(for: .seconds(checkInAnimationDuration), scheduler: DispatchQueue.main)
					.eraseToEffect()
				
			case .gotPathwayTemplates(let pathwayTemplates):
				print(pathwayTemplates)
				state.pathwayTemplates.update(pathwayTemplates)
				
			case .rows(let id, _):
				guard case .loaded(let pathways) = state.pathwayTemplates else { return .none }
				state.selectedPathway = pathways[id: id]
			default:
				break
			}
			return .none
		},
		chooseFormListReducer.pullback(
			state: \ChoosePathwayState.chooseConsentState,
			action: /ChoosePathwayContainerAction.chooseConsent,
			environment: makeFormEnv(_:)
		),
		choosePathwayReducer.pullback(
			state: \ChoosePathwayState.self,
			action: /ChoosePathwayContainerAction.choosePathway,
			environment: { $0 }),
		checkInReducer.optional.pullback(
			state: \ChoosePathwayState.checkIn,
			action: /ChoosePathwayContainerAction.checkIn,
			environment: { $0 }),
		checkInMiddleware.pullback(
			state: \ChoosePathwayState.self,
			action: /ChoosePathwayContainerAction.checkIn,
			environment: { $0 })
)

let choosePathwayReducer = Reducer<ChoosePathwayState, ChoosePathwayAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didTouchSelectConsentBackBtn:
		state.selectedPathway = nil
	}
	return .none
}

public enum ChoosePathwayAction {
	case didTouchSelectConsentBackBtn
}

public struct ChoosePathwayState: Equatable {
	
	let selectedJourney: Journey
	var selectedPathway: PathwayTemplate?
	var selectedConsentsIds: [HTMLForm.ID] = []
	var allConsents: IdentifiedArrayOf<FormTemplateInfo> = []
	var pathwayTemplates: LoadingState2<IdentifiedArrayOf<PathwayTemplate>> = .loading
	public var checkIn: CheckInContainerState?
	
	var chooseConsentState: ChooseFormState {
		get {
			ChooseFormState(templates: allConsents,
							selectedTemplatesIds: selectedConsentsIds,
							mode: .consentsPreCheckIn)
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
			LoadingStore(store.scope(state: { $0.pathwayTemplates }, action: { $0 }),
						 then: { (tmplts: Store<IdentifiedArrayOf<PathwayTemplate>,
												ChoosePathwayContainerAction>) in
							choosePathwayList(tmplts)
						 }
			)
			chooseFormNavLink
		}
		.journeyBase(self.viewStore.state.journey, .long)
	}

	fileprivate func choosePathwayList(_ tmplts: Store<IdentifiedArrayOf<PathwayTemplate>, ChoosePathwayContainerAction>) -> some View {
		return ScrollView {
			LazyVStack {
				ForEachStore(tmplts.scope(state: { $0 },
										  action: { .rows(id: $0, action: $1) }),
							 content: PathwayTemplateRow.init(store:))
			}
		}
	}
	
	var chooseFormNavLink: some View {
		NavigationLink.emptyHidden(self.viewStore.state.isChooseConsentShown,
								   ChooseFormList(store:
													self.store.scope(
														state: { $0.chooseConsentState },
														action: { .chooseConsent($0)}))
									.journeyBase(self.viewStore.state.journey, .long)
									.customBackButton {
										self.viewStore.send(.choosePathway(.didTouchSelectConsentBackBtn))
									}
		)
	}
}

public enum PathwayTemplateRowAction {
	case select
}

struct PathwayTemplateRow: View {
	let store: Store<PathwayTemplate, PathwayTemplateRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(alignment: .leading, spacing: 16) {
				HStack {
					Text(viewStore.title).font(.semibold20).foregroundColor(.black42)
					Spacer()
					Image(systemName: "list.bullet").foregroundColor(.blue2)
					Text(String("\(viewStore.steps.count)")).font(.semibold17)
				}
				Divider()
//				SecondaryButton(viewStore.title) {
//					viewStore.send(.select)
//				}
			}.padding([.leading, .trailing])
			.onTapGesture {
				viewStore.send(.select)
			}
		}.frame(height: 44)
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
