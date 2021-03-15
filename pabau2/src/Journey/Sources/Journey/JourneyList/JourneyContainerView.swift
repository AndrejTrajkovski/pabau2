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
import SharedComponents
import Appointments

public typealias JourneyEnvironment = (
	formAPI: FormAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

func makeFormEnv(_ journeyEnv: JourneyEnvironment) -> FormEnvironment {
	return FormEnvironment(formAPI: journeyEnv.formAPI,
						   userDefaults: journeyEnv.userDefaults)
}

let checkInMiddleware = Reducer<ChoosePathwayState, CheckInContainerAction, JourneyEnvironment> { _, action, _ in
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
	calendarDatePickerReducer.pullback(
		state: \JourneyContainerState.journey.selectedDate,
		action: /JourneyContainerAction.datePicker,
		environment: { $0 }),
	journeyContainerReducer2.pullback(
		state: \JourneyContainerState.journey,
		action: /JourneyContainerAction.self,
		environment: { $0 }
	),
	journeyFilterReducer.optional.pullback(
		state: \JourneyContainerState.journeyEmployeesFilter,
		action: /JourneyContainerAction.employeesFilter,
		environment: {
			return EmployeesFilterEnvironment(
				journeyAPI: $0.journeyAPI,
				userDefaults: $0.userDefaults)
		}),
	.init { state, action, env in
		switch action {
		case .toggleEmployees:
			if state.journeyEmployeesFilter != nil {
				state.journeyEmployeesFilter!.isShowingEmployees.toggle()
			}
		case .datePicker(.selectedDate(let date)):
			guard let locId = state.journeyEmployeesFilter?.locationId,
				  let employees = state.employees[locId] else { return .none }
			state.loadingState = .loading
			return env.journeyAPI.getAppointments(startDate: date, endDate: date, locationIds: [locId], employeesIds: Array(employees.map(\.id)), roomIds: [])
//				.map(with(date, curry(calendarResponseToJourneys(date:events:))))
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map { JourneyContainerAction.gotResponse($0) }
				.eraseToEffect()
		case .gotResponse(let result):
			print(result)
			switch result {
			case .success(let appointments):
				print("response: \(appointments)")
				guard let selectedLocationId = state.journey.selectedLocation?.id,
					  let employees = state.employees[selectedLocationId] else {
					return .none
				}
				state.appointments.refresh(events: appointments,
										   locationsIds: [selectedLocationId],
										   employees: employees.elements,
										   rooms: [])
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		default:
			break
		}
		return .none
	}
)

//JourneyState, ChooseFormAction
public let journeyContainerReducer2: Reducer<JourneyState, JourneyContainerAction, JourneyEnvironment> =
	.combine(
		journeyReducer.pullback(
					 state: \JourneyState.self,
					 action: /JourneyContainerAction.journey,
					 environment: { $0 }),
        journeyReducer.pullback(
                     state: \JourneyState.self,
                     action: /JourneyContainerAction.searchQueryChanged,
                     environment: { $0 }),
		choosePathwayContainerReducer.optional.pullback(
					 state: \JourneyState.choosePathway,
					 action: /JourneyContainerAction.choosePathway,
					 environment: { $0 })
)

let journeyReducer: Reducer<JourneyState, JourneyAction, JourneyEnvironment> =
	.combine (
		.init { state, action, environment in
            struct SearchJourneyId: Hashable {}

			switch action {
			case .selectedFilter(let filter):
				state.selectedFilter = filter

//			case .datePicker(.selectedDate(let date)):
//				state.loadingState = .loading
//				return environment.apiClient.getJourneys(date: date, searchTerm: nil)
//					.catchToEffect()
//					.map(JourneyAction.gotResponse)
//					.receive(on: DispatchQueue.main)
//					.eraseToEffect()
//			case .gotResponse(let result):
//				switch result {
//				case .success(let journeys):
//					state.journeys.formUnion(journeys)
//					state.loadingState = .gotSuccess
//
//				case .failure(let error):
//					state.loadingState = .gotError(error)
//				}

			case .searchedText(let searchText):
				state.searchText = searchText

//                return environment.apiClient
//                    .getJourneys(date: Date(), searchTerm: searchText)
//                    .receive(on: DispatchQueue.main)
//                    .eraseToEffect()
//                    .debounce(id: SearchJourneyId(), for: 0.3, scheduler: DispatchQueue.main)
//					.catchToEffect()
//                    .map(JourneyAction.gotResponse)
//                    .cancellable(id: SearchJourneyId(), cancelInFlight: true)
//

			case .selectedJourney(let journey):
				state.choosePathway = ChoosePathwayState(selectedJourney: journey)
			case .choosePathwayBackTap:
				state.selectedJourney = nil
			}
			return .none
	}
)

public struct JourneyContainerView: View {
	let store: Store<JourneyContainerState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>

    @State var showSearchBar: Bool = false

	struct ViewState: Equatable {
		let isChoosePathwayShown: Bool
		let selectedDate: Date
		let listedJourneys: [Journey]
		let isLoadingJourneys: Bool
        let searchQuery: String
		let navigationTitle: String
		init(state: JourneyContainerState) {
			self.isChoosePathwayShown = state.journey.choosePathway != nil
			self.selectedDate = state.journey.selectedDate
			self.listedJourneys = state.filteredJourneys()
			print("apps + ", state.appointments)
			print("filteredJourneys() + ", state.filteredJourneys())
			print("date:", state.journey.selectedDate)
            self.searchQuery = state.journey.searchText
			self.isLoadingJourneys = state.loadingState.isLoading
			self.navigationTitle = state.journey.selectedLocation?.name ?? "No Location Chosen"
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
		print("JourneyContainerView")
        return VStack {
            CalendarDatePicker.init(
                store: self.store.scope(
					state: { $0.journey.selectedDate },
                    action: { .datePicker($0)}),
                isWeekView: false,
                scope: .week
            )
            .padding(0)

            FilterPicker()

            if self.showSearchBar {
                SearchView(
                    placeholder: "Search",
                    text: viewStore.binding(
                    get: \.searchQuery,
                    send: { JourneyContainerAction.searchQueryChanged(JourneyAction.searchedText($0)) }
                    )
                )
                .isHidden(!self.showSearchBar)
                .padding([.leading, .trailing], 16)
            }

            JourneyList(self.viewStore.state.listedJourneys) {
                self.viewStore.send(.journey(.selectedJourney($0)))
            }.loadingView(.constant(self.viewStore.state.isLoadingJourneys),
						  Texts.fetchingJourneys)

            NavigationLink.emptyHidden(
                self.viewStore.state.isChoosePathwayShown,
				IfLetStore(
					store.scope(state: { $0.journey.choosePathway },
								action: { .choosePathway($0) }),
					then: { choosePathwayStore in
						ChoosePathway.init(store: choosePathwayStore)
							.navigationBarTitle("Choose Pathway")
							.customBackButton {
								self.viewStore.send(.journey(.choosePathwayBackTap))
							}
					}
				)
            )
            Spacer()
        }
		.navigationBarTitle(viewStore.navigationTitle, displayMode: .inline)
        .navigationBarItems(
            leading:
                HStack(spacing: 8.0) {
                    PlusButton {
                        withAnimation(Animation.easeIn(duration: 0.5)) {
                            self.viewStore.send(.addAppointmentTap)
                        }
                    }
                    Button(action: {
                        withAnimation {
                            self.showSearchBar.toggle()
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                    })
                },
            trailing:
                Button(action: {
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
}

func journeyCellAdapter(journey: Journey) -> JourneyCell {
	return JourneyCell(
		journey: journey,
        color: Color.init(hex: journey.first!.serviceColor ?? "#000000"),
		time: "12:30",
		imageUrl: journey.first!.clientPhoto ?? "",
		name: journey.first!.clientName ?? "",
		services: journey.servicesString,
		status: journey.first!.status?.name,
		employee: journey.first!.employeeName,
		paidStatus: "",
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
			ForEach(journeys.indices) { idx in
				journeyCellAdapter(journey: journeys[idx])
					.contextMenu {
						JourneyListContextMenu()
					}
					.onTapGesture { self.onSelect(journeys[idx]) }
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
