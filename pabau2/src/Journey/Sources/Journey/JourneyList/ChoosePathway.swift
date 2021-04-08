import SwiftUI
import Model
import Util
import ComposableArchitecture
import Form
import Overture
import Combine

public enum ChoosePathwayContainerAction {
	case rows(id: PathwayTemplate.ID, action: PathwayTemplateRowAction)
	case matchResponse(Result<Pathway, RequestError>)
	case gotPathwayTemplates(Result<IdentifiedArrayOf<PathwayTemplate>, RequestError>)
}

let choosePathwayContainerReducer: Reducer<ChoosePathwayState, ChoosePathwayContainerAction, JourneyEnvironment> =
	.combine(
		Reducer.init { state, action, env in
			switch action {
				
			case .gotPathwayTemplates(let pathwayTemplates):
				print(pathwayTemplates)
				state.pathwayTemplates.update(pathwayTemplates)
				
			case .rows(let id, _):
				guard case .loaded(let pathways) = state.pathwayTemplates else { return .none }
				state.selectedPathway = pathways[id: id]
				return env.journeyAPI.match(appointment: state.selectedAppointment,
											pathwayTemplateId: id)
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { ChoosePathwayContainerAction.matchResponse($0) }
					.eraseToEffect()
				
			default:
				break
			}
			return .none
		}
)

public struct ChoosePathwayState: Equatable {
	
	let selectedAppointment: Appointment
	var selectedPathway: PathwayTemplate?
	var pathwayTemplates: LoadingState2<IdentifiedArrayOf<PathwayTemplate>> = .loading
}

public struct ChoosePathway: View {
	let store: Store<ChoosePathwayState, ChoosePathwayContainerAction>
	@ObservedObject var viewStore: ViewStore<State, ChoosePathwayContainerAction>
	struct State: Equatable {
		let isChooseConsentShown: Bool
		let appointment: Appointment?
		init(state: ChoosePathwayState) {
			self.isChooseConsentShown = state.selectedPathway != nil
			self.appointment = state.selectedAppointment
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
		LoadingStore(store.scope(state: { $0.pathwayTemplates }, action: { $0 }),
					 then: { (tmplts: Store<IdentifiedArrayOf<PathwayTemplate>,
											ChoosePathwayContainerAction>) in
						choosePathwayList(tmplts)
					 }
		)
		.journeyBase(self.viewStore.state.appointment, .long)
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
