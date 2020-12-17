import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture
import SwiftDate
import CasePaths
import Form
import Overture
import Filters

public typealias JourneyEnvironment = (
	journeyAPI: JourneyAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig
)

func makeFormEnv(_ journeyEnv: JourneyEnvironment) -> FormEnvironment {
	return FormEnvironment(formAPI: journeyEnv.formAPI,
						   userDefaults: journeyEnv.userDefaults)
}

let checkInMiddleware2 = Reducer<JourneyState, ChooseFormAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .proceed:
		guard let selJ = state.selectedJourney,
			let selP = state.selectedPathway else { return .none }
		state.checkIn = CheckInContainerState(
			journey: selJ,
			pathway: selP,
			patientDetails: PatientDetails.mock,
			medHistory: FormTemplate.getMedHistory(),
			consents: state.allConsents.filter(
				pipe(get(\.id), state.selectedConsentsIds.contains)
			),
			allConsents: state.allConsents,
			photosState: PhotosState.init(SavedPhoto.mock())
		)
	default:
		return .none
	}
	return .none
}

let checkInMiddleware = Reducer<JourneyState, CheckInContainerAction, JourneyEnvironment> { _, action, _ in
	switch action {
//	case .patient(.topView(.onXButtonTap)),
//			 .doctorSummary(.xOnDoctorCheckIn):
//		state.selectedJourney = nil
//		state.selectedPathway = nil
//		state.checkIn?.didGoBackToPatientMode = false
//		state.checkIn = nil
//	case .doctor(.checkInBody(.completeJourney(.onCompleteJourney))),
//		.doctor(.checkInBody(.footer(.completeJourney(.onCompleteJourney)))):
//		state.selectedJourney = nil
//		state.selectedPathway = nil
//		state.checkIn?.didGoBackToPatientMode = false
//		state.checkIn = nil
	default:
		return .none
	}
	return .none
}

public let journeyContainerReducer: Reducer<JourneyContainerState, JourneyContainerAction, JourneyEnvironment> = .combine(
	journeyContainerReducer2.pullback(
		state: \JourneyContainerState.journey,
		action: /JourneyContainerAction.self,
		environment: { $0 }
	),
	.init { state, action, _ in
		switch action {
		case .toggleEmployees:
			state.employeesFilter.isShowingEmployees.toggle()
		default:
			break
		}
		return .none
	}
)

//JourneyState, ChooseFormAction
public let journeyContainerReducer2: Reducer<JourneyState, JourneyContainerAction, JourneyEnvironment> =
	.combine(
		checkInMiddleware2.pullback(
			state: \JourneyState.self,
			action: /JourneyContainerAction.choosePathway..ChoosePathwayContainerAction.chooseConsent,
			environment: { $0 }),
		journeyReducer.pullback(
					 state: \JourneyState.self,
					 action: /JourneyContainerAction.journey,
					 environment: { $0 }),
		choosePathwayContainerReducer.pullback(
					 state: \JourneyState.choosePathway,
					 action: /JourneyContainerAction.choosePathway,
					 environment: { $0 }),
		checkInReducer.optional.pullback(
			state: \JourneyState.checkIn,
			action: /JourneyContainerAction.checkIn,
			environment: { $0 }),
		checkInMiddleware.pullback(
			state: \JourneyState.self,
			action: /JourneyContainerAction.checkIn,
			environment: { $0 })
)

let journeyReducer: Reducer<JourneyState, JourneyAction, JourneyEnvironment> =
	.combine (
		calendarDatePickerReducer.pullback(
			state: \JourneyState.selectedDate,
			action: /JourneyAction.datePicker,
			environment: { $0 }),
		.init { state, action, environment in
			switch action {
			case .selectedFilter(let filter):
				state.selectedFilter = filter
			case .datePicker(.selectedDate(let date)):
				state.loadingState = .loading
				return environment.journeyAPI.getJourneys(date: date)
					.map(JourneyAction.gotResponse)
					.eraseToEffect()
			case .gotResponse(let result):
				switch result {
				case .success(let journeys):
					state.journeys.formUnion(journeys)
					state.loadingState = .gotSuccess
				case .failure:
					state.loadingState = .gotError
				}
			case .searchedText(let searchText):
				state.searchText = searchText
			case .selectedJourney(let journey):
				state.selectedJourney = journey
			case .choosePathwayBackTap:
				state.selectedJourney = nil
			case .loadJourneys:
				state.loadingState = .loading
				return environment.journeyAPI
					.getJourneys(date: Date())
					.map(JourneyAction.gotResponse)
					.eraseToEffect()
			}
			return .none
	}
)

public struct JourneyContainerView: View {
	let store: Store<JourneyContainerState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>
	struct ViewState: Equatable {
		let isChoosePathwayShown: Bool
		let selectedDate: Date
		let listedJourneys: [Journey]
		let isLoadingJourneys: Bool
		init(state: JourneyContainerState) {
			self.isChoosePathwayShown = state.journey.selectedJourney != nil
			self.selectedDate = state.journey.selectedDate
			self.listedJourneys = state.filteredJourneys
			self.isLoadingJourneys = state.journey.loadingState.isLoading
			UITableView.appearance().separatorStyle = .none
		}
	}
	public init(_ store: Store<JourneyContainerState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
	}
	public var body: some View {
		VStack {
			CalendarDatePicker.init(
				store: self.store.scope(
					state: { $0.journey.selectedDate },
					action: { .journey(.datePicker($0))}),
				isWeekView: false,
				scope: .week
			)
			.padding(0)
			FilterPicker()
			JourneyList(self.viewStore.state.listedJourneys) {
				self.viewStore.send(.journey(.selectedJourney($0)))
			}.loadingView(.constant(self.viewStore.state.isLoadingJourneys),
						  Texts.fetchingJourneys)
			NavigationLink.emptyHidden(self.viewStore.state.isChoosePathwayShown,
									   ChoosePathway(store: self.store.scope(state: { $0.journey.choosePathway
									   }, action: { .choosePathway($0)}))
									   .navigationBarTitle("Choose Pathway")
									   .customBackButton {
										self.viewStore.send(.journey(.choosePathwayBackTap))
									}
			)
			Spacer()
		}
		.navigationBarTitle("Manchester", displayMode: .inline)
		.navigationBarItems(leading:
			HStack(spacing: 8.0) {
				PlusButton {
					withAnimation(Animation.easeIn(duration: 0.5)) {
						self.viewStore.send(.addAppointmentTap)
					}
				}
				Button(action: {

				}, label: {
					Image(systemName: "magnifyingglass")
						.font(.system(size: 20))
						.frame(width: 44, height: 44)
				})
			}, trailing:
			Button (action: {
				withAnimation {
					self.viewStore.send(.toggleEmployees)
				}
			}, label: {
				Image(systemName: "person")
					.font(.system(size: 20))
					.frame(width: 44, height: 44)
			})
		)
	}

	struct ChoosePathwayEither: View {
		let store: Store<JourneyState, JourneyContainerAction>
		let isSelectedJourney: Bool
		var body: some View {
			ViewBuilder.buildBlock(
				(isSelectedJourney) ?
					ViewBuilder.buildEither(second:
						ChoosePathway(store: self.store.scope(state: { $0.choosePathway
						}, action: { .choosePathway($0)}))
					)
					:
					ViewBuilder.buildEither(first:
						EmptyView()
				)
			)
		}
	}
}

func journeyCellAdapter(journey: Journey) -> JourneyCell {
	return JourneyCell(
		journey: journey,
		color: Color.init(hex: journey.appointments.first!.service.color),
		time: "12:30",
		imageUrl: journey.patient.avatar,
		name: journey.patient.firstName + " " + journey.patient.lastName,
		services: journey.servicesString,
		status: journey.appointments.first!.status?.name,
		employee: journey.employee.name,
		paidStatus: journey.paid,
		stepsComplete: 0,
		stepsTotal: 3)
}

struct JourneyList: View {
	let journeys: [Journey]
	let onSelect: (Journey) -> Void
	init (_ journeys: [Journey],
				_ onSelect: @escaping (Journey) -> Void) {
		self.journeys = journeys
		self.onSelect = onSelect
	}
	var body: some View {
		List {
			ForEach(journeys) { journey in
				journeyCellAdapter(journey: journey)
					.contextMenu {
						JourneyListContextMenu()
					}
					.onTapGesture { self.onSelect(journey) }
					.listRowInsets(EdgeInsets())
			}
		}.id(UUID())
	}
}

struct JourneyCell: View {
	let journey: Journey
	let color: Color
	let time: String
	let imageUrl: String?
	let name: String
	let services: String
	let status: String?
	let employee: String
	let paidStatus: String
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				JourneyColorRect(color: color)
				Spacer()
				Group {
					Text(time).font(Font.semibold11)
					Spacer()
					JourneyAvatarView(journey: journey, font: .regular18, bgColor: .accentColor)
						.frame(width: 55, height: 55)
					VStack(alignment: .leading, spacing: 4) {
						Text(name).font(Font.semibold14)
						Text(services).font(Font.regular12)
						Text(status ?? "").font(.medium9).foregroundColor(.deepSkyBlue)
					}.frame(maxWidth: 158, alignment: .leading)
				}
				Spacer()
				IconAndText(Image(systemName: "person"), employee)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				IconAndText(Image(systemName: "bag"), paidStatus)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
				Spacer()
			}
			Divider().frame(height: 1)
		}
		.frame(minWidth: 0, maxWidth: .infinity, idealHeight: 97)
	}
}

struct IconAndText: View {
	let text: String
	let image: Image
	let textColor: Color
	init(_ image: Image,
			 _ text: String,
			 _ textColor: Color = .black) {
		self.image = image
		self.text = text
		self.textColor = textColor
	}
	var body: some View {
		HStack {
			image
				.resizable()
				.scaledToFit()
				.foregroundColor(.blue2)
				.frame(width: 20, height: 20)
			Text(text)
				.font(Font.semibold11)
				.foregroundColor(textColor)
		}
	}
}

struct StepsStatusView: View {
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		NumberEclipse(text: "\(stepsComplete)/\(stepsTotal)")
	}
}

struct JourneyColorRect: View {
	public let color: Color
	var body: some View {
		Rectangle()
			.foregroundColor(color)
			.frame(width: 8.0)
	}
}

struct FilterPicker: View {
	@State private var filter: CompleteFilter = .all
	var body: some View {
		VStack {
			Picker(selection: $filter, label: Text("Filter")) {
				ForEach(CompleteFilter.allCases, id: \.self) { (filter: CompleteFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}
