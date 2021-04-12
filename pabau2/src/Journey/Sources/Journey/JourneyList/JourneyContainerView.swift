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
import Combine

let checkInMiddleware = Reducer<JourneyState, CheckInContainerAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .patient(.stepsView(.onXTap)):
		state.checkIn = nil
		return .none
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
		environment: { $0 }
	),
	journeyReducer.pullback(
				 state: \JourneyContainerState.journey,
				 action: /JourneyContainerAction.journey,
				 environment: { $0 }
	),
	journeyReducer.pullback(
				 state: \JourneyContainerState.journey,
				 action: /JourneyContainerAction.searchQueryChanged,
				 environment: { $0 }
	),
	journeyFilterReducer.optional.pullback(
		state: \JourneyContainerState.journeyEmployeesFilter,
		action: /JourneyContainerAction.employeesFilter,
		environment: {
			return EmployeesFilterEnvironment(
				journeyAPI: $0.journeyAPI,
				userDefaults: $0.userDefaults)
		}
	),
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
				state.appointments = .init(events: appointments)
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

let journeyReducer: Reducer<JourneyState, JourneyAction, JourneyEnvironment> =
	.combine (
		choosePathwayContainerReducer.optional().pullback(
					 state: \JourneyState.choosePathway,
					 action: /JourneyAction.choosePathway,
					 environment: { $0 }),
		.init { state, action, environment in
            struct SearchJourneyId: Hashable {}

			switch action {
			
			case .selectedFilter(let filter):
				state.selectedFilter = filter
				
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

			case .selectedAppointment(let appointment):
				state.choosePathway = ChoosePathwayState(selectedAppointment: appointment)
				return environment.journeyAPI.getPathwayTemplates()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { .choosePathway(.gotPathwayTemplates($0))  }
				
			case .choosePathwayBackTap:
				state.choosePathway = nil
				
			case .choosePathway(.matchResponse(let pathwayResult)):
				print(pathwayResult)
				switch pathwayResult {
				case .success(let pathway):
					
					state.checkIn = CheckInContainerState(appointment: state.choosePathway!.selectedAppointment,
														  pathway: pathway,
														  pathwayTemplate: state.choosePathway!.selectedPathway!,
														  patientDetails: ClientBuilder.empty,
														  medicalHistories: [],
														  consents: [],
														  allConsents: [],
														  photosState: PhotosState.init(SavedPhoto.mock()
														  )
					)
					
					return Just(JourneyAction.checkIn(CheckInContainerAction.showPatientMode))
						.delay(for: .seconds(checkInAnimationDuration), scheduler: DispatchQueue.main)
						.eraseToEffect()
					
				case .failure(let error):
					print(error)
				}
				
			case .checkIn(_):
				break
				
			case .choosePathway(.rows(id: let id, action: let action)):
				break
				
			case .choosePathway(.gotPathwayTemplates):
				break
			}
			return .none
	},
		checkInReducer.optional.pullback(
			state: \JourneyState.checkIn,
			action: /JourneyAction.checkIn,
			environment: { $0 }),
		checkInMiddleware.pullback(
			state: \JourneyState.self,
			action: /JourneyAction.checkIn,
			environment: { $0 }
		)
)

public struct JourneyContainerView: View {
	let store: Store<JourneyContainerState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>

    @State var showSearchBar: Bool = false
	
	struct ViewState: Equatable {
		let isChoosePathwayShown: Bool
		let selectedDate: Date
		let listedAppointments: [Appointment]
		let isLoadingJourneys: Bool
        let searchQuery: String
		let navigationTitle: String
		init(state: JourneyContainerState) {
			self.isChoosePathwayShown = state.journey.choosePathway != nil
			self.selectedDate = state.journey.selectedDate
			self.listedAppointments = state.appointments.appointments[state.journey.selectedDate]?.elements ?? []
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
		VStack {
            datePicker

            FilterPicker()

            if self.showSearchBar {
                searchBar
            }

            JourneyList(self.viewStore.state.listedAppointments) {
                self.viewStore.send(.journey(.selectedAppointment($0)))
            }.loadingView(.constant(self.viewStore.state.isLoadingJourneys),
						  Texts.fetchingJourneys)
			
			choosePathwayLink
			
            Spacer()
        }
		.navigationBarTitle(viewStore.navigationTitle, displayMode: .inline)
        .navigationBarItems(leading: leadingItems, trailing: trailingItems)
    }
	
	var datePicker: some View {
		CalendarDatePicker.init(
			store: self.store.scope(
				state: { $0.journey.selectedDate },
				action: { .datePicker($0)}),
			isWeekView: false,
			scope: .week
		)
		.padding(0)
	}
	
	var searchBar: some View {
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
	
	var leadingItems: some View {
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
		}
	}
	
	var trailingItems: some View {
		Button(action: {
			withAnimation {
				self.viewStore.send(.toggleEmployees)
			}
		}, label: {
			Image(systemName: "person")
				.font(.system(size: 20))
				.frame(width: 44, height: 44)
		})
	}
		
	var choosePathwayLink: some View {
		NavigationLink.emptyHidden(
			viewStore.state.isChoosePathwayShown,
			IfLetStore(
				store.scope(state: { $0.journey.choosePathway },
							action: { .journey(.choosePathway($0)) }),
				then: { choosePathwayStore in
					ChoosePathway.init(store: choosePathwayStore)
						.navigationBarTitle("Choose Pathway")
						.customBackButton {
							viewStore.send(.journey(.choosePathwayBackTap))
						}
				}
			)
		)
	}
}

struct JourneyList: View {
	let appointments: [Appointment]
	let onSelect: (Appointment) -> Void
	init (_ appointments: [Appointment],
				_ onSelect: @escaping (Appointment) -> Void) {
		self.appointments = appointments
		self.onSelect = onSelect
	}
	var body: some View {
		List {
			ForEach(appointments.indices) { idx in
				JourneyCell.init(appointment: appointments[idx])
					.contextMenu {
						JourneyListContextMenu()
					}
					.onTapGesture { self.onSelect(appointments[idx]) }
					.listRowInsets(EdgeInsets())
			}
		}.id(UUID())
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
