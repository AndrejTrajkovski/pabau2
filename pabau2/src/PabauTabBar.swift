import SwiftUI
import ComposableArchitecture
import Model
import Util
import Journey
import Clients
import Calendar
import Filters
import JZCalendarWeekView
import AddAppointment
import Communication
import Intercom
import Appointments
import CoreDataModel
import CalendarList
import ChooseLocationAndEmployee
import ToastAlert
import Combine
import Form
import Overture

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig,
	repository: Repository,
	audioPlayer: AudioPlayerProtocol
)

public struct TabBarState: Equatable {
	var checkIn: CheckInContainerState?
	var clients: ClientsState
	var calendar: CalendarState
	var settings: SettingsState
	var communication: CommunicationState
	var addAppointment: AddAppointmentState?
}

public enum TabBarAction {
	case settings(SettingsAction)
	case clients(ClientsAction)
	case calendar(CalendarAction)
	case addAppointment(AddAppointmentAction)
	case communication(CommunicationAction)
	case checkIn(CheckInContainerAction)
	case delayStartPathway(state: CheckInContainerState)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	@ObservedObject var viewStore: ViewStore<ViewState, TabBarAction>

	struct ViewState: Equatable {
		let isShowingCheckin: Bool
		let isShowingAddAppointment: Bool
		let isShowingAppDetails: Bool

		init(state: TabBarState) {
			self.isShowingCheckin = state.checkIn != nil
			self.isShowingAddAppointment = state.addAppointment != nil
			self.isShowingAppDetails = state.calendar.appDetails != nil
		}
	}

    init (store: Store<TabBarState, TabBarAction>) {
        self.store = store
        self.viewStore = ViewStore(
            store.scope(
                state: ViewState.init(state:),
                action: { $0 }
            )
        )
    }

	var body: some View {
		TabView {
			calendar()
			clients()
			settings()
			communication()
        }
        .modalLink(
            isPresented: .constant(self.viewStore.state.isShowingCheckin),
            linkType: ModalTransition.circleReveal,
            destination: {
                checkIn()
            }
        )
		.fullScreenCover(
            isPresented: .constant(self.viewStore.state.isShowingAddAppointment)
        ) {
			addAppointment()
		}
	}

    fileprivate func calendar() -> some View {
        CalendarContainer(
            store: store.scope(
                state: { $0.calendar },
                action: { .calendar($0) }
            )
        )
        .tabItem {
            Image(systemName: "calendar")
            Text("Calendar")
        }
    }

	fileprivate func clients() -> some View {
		 ClientsNavigationView(
			self.store.scope(
				state: { $0.clients },
				action: { .clients($0) })
		).tabItem {
			Image(systemName: "rectangle.stack.person.crop")
			Text(Texts.clients)
		}.onAppear {
			self.viewStore.send(.clients(ClientsAction.onAppearNavigationView))
		}
	}

    fileprivate func settings() -> some View {
        Settings(store: store.scope(
                    state: { $0.settings },
                    action: { .settings($0)})
        )
        .tabItem {
            Image(systemName: "gear")
            Text("Settings")
        }
    }

    fileprivate func communication() -> some View {
        CommunicationView(
            store:
                store.scope(state: { $0.communication },
                            action: { .communication($0)}))
            .tabItem {
                Image(systemName: "ico-tab-tasks")
                Text("Intercom")
            }
    }
	
	fileprivate func checkIn() -> IfLetStore<CheckInContainerState, CheckInContainerAction, CheckInContainer?> {
		print("checkIn()")
		return IfLetStore(self.store.scope(
			state: { $0.checkIn },
			action: { .checkIn($0) }
		),
		then: CheckInContainer.init(store:))
	}
	
    fileprivate func addAppointment() -> IfLetStore<AddAppointmentState, AddAppointmentAction, AddAppointment?> {
        IfLetStore(
            self.store.scope(
                state: { $0.addAppointment },
                action: { .addAppointment($0)}
            ),
            then: AddAppointment.init(store:))
    }
}

private let audioQueue = DispatchQueue(label: "Audio Dispatch Queue")
struct TimerId: Hashable { }

public let tabBarReducer: Reducer<
	TabBarState,
	TabBarAction,
	TabBarEnvironment
> = Reducer.combine(
    checkInContainerOptionalReducer.pullback(
		state: \TabBarState.checkIn,
		action: /TabBarAction.checkIn,
		environment: makeJourneyEnv(_:)
	),
	showAddAppointmentReducer.pullback(
		state: \TabBarState.self,
		action: /TabBarAction.calendar,
		environment: { $0 }
	),
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: makeClientsEnv(_:)
	),
	calendarContainerReducer.pullback(
		state: \TabBarState.calendar,
		action: /TabBarAction.calendar,
		environment: {
			return CalendarEnvironment(
				journeyAPI: $0.journeyAPI,
				clientsAPI: $0.clientsAPI,
				userDefaults: $0.userDefaults,
                repository: $0.repository
            )
        }),
    
    Reducer<
        TabBarState,
        TabBarAction,
        TabBarEnvironment
    >.init { state, action, env in
		switch action {
        
        case .checkIn(.loaded(.patient(.steps(.steps(let idx, .stepType(let stepTypeAction)))))):
            return updateAppointmentsStepsComplete(idx: idx, stepTypeAction: stepTypeAction, state: &state)
        case .checkIn(.loaded(.doctor(.steps(.steps(let idx, .stepType(let stepTypeAction)))))):
            return updateAppointmentsStepsComplete(idx: idx, stepTypeAction: stepTypeAction, state: &state)
            
		case .delayStartPathway(let checkInState):
			
			var returnEffects: [Effect<TabBarAction, Never>] = [
				env.audioPlayer
					.playCheckInSound()
					.receive(on: audioQueue)
					.fireAndForget(),
				
				Effect(value: TabBarAction.checkIn(CheckInContainerAction.checkInAnimationEnd))
					.delay(for: .seconds(checkInAnimationDuration), scheduler: DispatchQueue.main)
					.eraseToEffect()
			]
			
			switch checkInState.loadingOrLoaded {
			
			case .loading(let loadingState):
				
				let getCombinedPathwaysResponse = getCombinedPathwayResponse(journeyAPI: env.journeyAPI,
																			 checkInState: loadingState)
					.map {
						TabBarAction.checkIn(.gotPathwaysResponse($0))
					}
				returnEffects.append(getCombinedPathwaysResponse)
				
			case .loaded(let loadedState):
				
                let getForms = getCheckInFormsOneAfterAnother(pathway: loadedState.pathway,
                                                              template: loadedState.pathwayTemplate,
                                                              journeyMode: .patient,
                                                              formAPI: env.formAPI,
                                                              clientId: loadedState.appointment.customerId)
					
                returnEffects.append(getForms.map(TabBarAction.checkIn))
			}
			
            state.checkIn = checkInState
            
			return .merge(returnEffects)
			
		case .calendar(.appDetails(.choosePathwayTemplate(.matchResponse(.success(let pathway))))):
			
			guard let appDetails = state.calendar.appDetails,
				  let template = appDetails.choosePathwayTemplate?.selectedPathway else { return .none }
			
            var app = state.calendar.appDetails!.app
            app.pathways.append(PathwayInfo.init(pathway, template))
            state.calendar.replace(app: CalendarEvent.appointment(app))
			state.calendar.appDetails = nil
			
			let loadedState = CheckInLoadedState(appointment: appDetails.app,
													pathway: pathway,
													template: template)
			print("here:", pathway, template)
			let checkInState = CheckInContainerState(loadedState: loadedState)
			
			return .merge([
				Effect.init(value: TabBarAction.delayStartPathway(state: checkInState))
					.delay(for: 0.2, scheduler: DispatchQueue.main)
					.eraseToEffect(),
				
				.cancel(id: ToastTimerId())
			])
			
		case .calendar(.appDetails(.choosePathway(.rows(let id, .select)))):
			guard let app = state.calendar.appDetails?.app,
				  let pathwayInfo = app.pathways[id: id] else { return .none }
			
			state.calendar.appDetails = nil
			
			let loadingCheckInState = CheckInLoadingState(appointment: app,
														  pathwayId: pathwayInfo.pathwayId,
														  pathwayTemplateId: pathwayInfo.pathwayTemplateId,
														  pathwaysLoadingState: .loading)
			let checkInState = CheckInContainerState(loadingState: loadingCheckInState)
			
			return .merge([
				Effect.init(value: TabBarAction.delayStartPathway(state: checkInState))
					.delay(for: 0.2, scheduler: DispatchQueue.main)
					.eraseToEffect(),
				
				.cancel(id: ToastTimerId())
			])
			
		case .calendar(.onAddEvent(.appointment)):
			state.calendar.isAddEventDropdownShown = false
            let chooseLocAndEmp = ChooseLocationAndEmployeeState(
                locations: state.calendar.locations,
                employees: state.calendar.employees
            )
            state.addAppointment = AddAppointmentState(chooseLocAndEmp: chooseLocAndEmp,
                                                       startDate: state.calendar.selectedDate)
		case .addAppointment(
				.chooseLocAndEmp(
					.chooseLocation(
						.gotLocationsResponse(let result)))):
			state.calendar.update(locationsResult: result.map(\.state))
		case .addAppointment(
				.chooseLocAndEmp(
					.chooseEmployee(
						.gotEmployeeResponse(let result)))):
			state.calendar.update(employeesResult: result.map(\.state))
        case .addAppointment(AddAppointmentAction.appointmentCreated(let response)):
            return Effect(value: TabBarAction.calendar(.appointmentCreatedResponse(response)))
		default:
			break
		}
		return .none
	},
	addAppointmentReducer.pullback(
		state: \TabBarState.addAppointment,
		action: /TabBarAction.addAppointment,
		environment: {
			return AddAppointmentEnv(
				journeyAPI: $0.journeyAPI,
				clientAPI: $0.clientsAPI,
				userDefaults: $0.userDefaults,
				repository: $0.repository
			)
		}
	),
	settingsReducer.pullback(
		state: \TabBarState.settings,
		action: /TabBarAction.settings,
		environment: {
			SettingsEnvironment(
				loginAPI: $0.loginAPI,
				clientsAPI: $0.clientsAPI,
				formAPI: $0.formAPI,
				userDefaults: $0.userDefaults)
		}
	),

	communicationReducer.pullback(
		state: \TabBarState.communication,
		action: /TabBarAction.communication,
		environment: { $0 }
	),
	.init { _, action, _ in
		switch action {
		case .communication(.liveChat):
			Intercom.registerUser(withEmail: "a@a.com")
			Intercom.presentMessenger()
			return .none
		case .communication(.helpGuides):
			//Intercom.presentHelpCenter()
			return .none
		case .communication(.carousel):
			Intercom.presentCarousel("13796318")
			return .none
		default:
			break
		}

		return .none
	}
)

public let showAddAppointmentReducer: Reducer<TabBarState, CalendarAction, Any> = .init { state, action, _ in
	
    var chooseLocAndEmp = ChooseLocationAndEmployeeState(
        locations: state.calendar.locations,
        employees: state.calendar.employees
    )

	switch action {
	case .employee(.addAppointment(let startDate, let durationMins, let dropKeys)):
		let (location, subsection) = dropKeys
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		chooseLocAndEmp.chosenLocationId = location
		chooseLocAndEmp.chosenEmployeeId = subsection
		state.addAppointment = AddAppointmentState(
			startDate: startDate,
			endDate: endDate,
			chooseLocAndEmp: chooseLocAndEmp
		)
	case .room(.addAppointment(let startDate, let durationMins, let dropKeys)):
		let (location, subsection) = dropKeys
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		let room = state.calendar.rooms[location]?[id: subsection]
		//TODO: Add room in AddAppointment
		state.addAppointment = AddAppointmentState(
			startDate: startDate,
			endDate: endDate,
			chooseLocAndEmp: chooseLocAndEmp
		)
	case .week(.addAppointment(let startOfDayDate, let startDate, let durationMins)):
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		state.addAppointment = AddAppointmentState(startDate: startDate,
												   endDate: endDate,
												   chooseLocAndEmp: chooseLocAndEmp)
	case .showAddApp(let start, let end, let employee):
		state.addAppointment = AddAppointmentState(
			startDate: start,
			endDate: end,
			chooseLocAndEmp: chooseLocAndEmp
		)
	case .week(.editAppointment(let appointment)):
		state.addAppointment = AddAppointmentState(editingAppointment: appointment,
												   startDate: appointment.start_date,
												   endDate: appointment.end_date,
												   chooseLocAndEmp: chooseLocAndEmp)
	default:
		break
	}
	return .none
}

extension TabBarState {
	public init() {
		self.clients = ClientsState()
		self.calendar = CalendarState()
		self.settings = SettingsState()
		self.communication = CommunicationState()
	}
}

fileprivate func updateAppointmentsStepsComplete(idx: Int, stepTypeAction: StepTypeAction, state: inout TabBarState) -> Effect<TabBarAction, Never> {
    guard stepTypeAction.isStepCompleteAction else { return .none }
    if case .loaded(let loadedState) = state.checkIn?.loadingOrLoaded {
        var app = loadedState.appointment
        guard var pathwayInfo = app.pathways[id: loadedState.pathway.id] else { return .none }
        let allStatuses = (loadedState.patientCheckIn.stepStates + loadedState.doctorCheckIn.stepStates).map(\.status)
        let completeCount = allStatuses.filter { $0 == .completed || $0 == .skipped }.count
        pathwayInfo.stepsTotal = .right(allStatuses.count)
        pathwayInfo.stepsComplete = .right(completeCount)
        app.pathways[id: pathwayInfo.id] = pathwayInfo
        state.calendar.replace(app: CalendarEvent.appointment(app))
    }
    return .none
}
