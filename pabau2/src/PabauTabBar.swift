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
//import Intercom
import Appointments
import CoreDataModel
import CalendarList
import ChooseLocationAndEmployee
import ToastAlert
import Combine
import Form

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
	var checkIn: CheckInNavigationState?
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
	case delayStartPathway(state: CheckInNavigationState)
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
	
	fileprivate func checkIn() -> IfLetStore<CheckInNavigationState, CheckInContainerAction, CheckInNavigationView?> {
		print("checkIn()")
		return IfLetStore(self.store.scope(
			state: { $0.checkIn },
			action: { .checkIn($0) }
		),
		then: CheckInNavigationView.init(store:))
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

func getForms(stepEntries: [Dictionary<Step.Id, StepEntry>.Element], formAPI: FormAPI, clientid: Client.ID) -> [Effect<CheckInPatientAction, Never>] {
	return stepEntries
		.compactMap {
			return getForm(stepId: $0.key, stepEntry: $0.value, formAPI: formAPI, clientId: clientid)
		}
}

func getForm(stepId: Step.Id, stepEntry: StepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<CheckInPatientAction, Never>? {
	
	func getHTMLForm(formTemplateId: HTMLForm.ID) -> Effect<Result<HTMLForm, RequestError>, Never> {
		return formAPI.getForm(templateId: formTemplateId, entryId: stepEntry.htmlFormInfo!.formEntryId)
			.catchToEffect()
	}
	
	if stepEntry.stepType.isHTMLForm {
		guard let formTemplateId = stepEntry.htmlFormInfo?.templateIdToLoad else { return nil }
		return getHTMLForm(formTemplateId: formTemplateId)
			.map {
				CheckInPatientAction.htmlForms(id: stepId, action: .htmlForm(HTMLFormAction.gotForm($0)))
			}
	} else {
		switch stepEntry.stepType {
		case .patientdetails:
			return formAPI.getPatientDetails(clientId: clientId)
				.map(ClientBuilder.init(client:))
				.catchToEffect()
				.map(PatientDetailsParentAction.gotGETResponse)
				.map(CheckInPatientAction.patientDetails)
		case .checkpatient:
			return nil
		case .photos:
			return nil
		case .aftercares:
			return nil
		case .patientComplete:
			return nil
		default:
			return nil
		}
	}
}

public let tabBarReducer: Reducer<
	TabBarState,
	TabBarAction,
	TabBarEnvironment
> = Reducer.combine(
	checkInParentReducer.optional().pullback(
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

	.init { state, action, env in
		switch action {
		case .delayStartPathway(let checkInState):
			
			state.checkIn = checkInState
			
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
						TabBarAction.checkIn(.loading(.gotCombinedPathwaysResponse($0)))
					}
				returnEffects.append(getCombinedPathwaysResponse)
				
			case .loaded(let loadedState):
				
				let getPatientForms = loadedState.patientCheckIn.htmlForms.compactMap { htmlStepState in
					return htmlStepState.htmlFormParentState?.getForm(formAPI: env.formAPI)
						.map {
							TabBarAction.checkIn(CheckInContainerAction.patient(.htmlForms(id: htmlStepState.id, action: .htmlForm($0))))
						}
				}
				
				let getPatientFormsOneAfterAnother = Effect.concatenate(getPatientForms)
				
				returnEffects.append(getPatientFormsOneAfterAnother)
			}
			
			return .merge(returnEffects)
			
		case .calendar(.appDetails(.choosePathwayTemplate(.matchResponse(.success(let pathway))))):
			
			guard let appDetails = state.calendar.appDetails,
				  let template = appDetails.choosePathwayTemplate?.selectedPathway else { return .none }
			
			state.calendar.appDetails = nil
			
			let loadedState = CheckInLoadedState(appointment: appDetails.app,
													pathway: pathway,
													template: template)
			print("here:", pathway, template)
			let checkInState = CheckInNavigationState(loadedState: loadedState)
			
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
			let checkInState = CheckInNavigationState(loadingState: loadingCheckInState)
			
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
			state.addAppointment = AddAppointmentState(chooseLocAndEmp: chooseLocAndEmp)
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
//			Intercom.registerUser(withEmail: "a@a.com")
//			Intercom.presentMessenger()
			return .none
		case .communication(.helpGuides):
			//Intercom.presentHelpCenter()
			return .none
		case .communication(.carousel):
			//Intercom.presentCarousel("13796318")
			return .none
		default:
			break
		}

		return .none
	}
)

public let showAddAppointmentReducer: Reducer<TabBarState, CalendarAction, Any> = .init { state, action, env in
	
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
