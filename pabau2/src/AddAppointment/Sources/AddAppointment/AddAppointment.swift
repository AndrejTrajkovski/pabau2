import SwiftUI
import Model
import ComposableArchitecture
import Util
import Form
import SharedComponents

public typealias AddAppointmentEnv = (journeyAPI: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig)

public struct AddAppointmentState: Equatable {
    let editingAppointment: Appointment?

    var reminder: Bool
    var email: Bool
    var sms: Bool
    var feedback: Bool
    var isAllDay: Bool
    var clients: ChooseClientsState
    var startDate: Date
    var services: ChooseServiceState
    var durations: SingleChoiceLinkState<Duration>
    var with: ChooseEmployeesState
    var participants: SingleChoiceLinkState<Employee>
    var note: String = ""

    var showsLoadingSpinner: Bool

    var appointmentsBody: AppointmentBuilder {
        if let editingAppointment = editingAppointment {
            return AppointmentBuilder(appointment: editingAppointment)
        }
        
        return AppointmentBuilder(
            isAllDay: self.isAllDay,
            clientID: self.clients.chosenClient?.id.rawValue,
            employeeID: self.with.chosenEmployee?.id.rawValue,
            serviceID: self.services.chosenService?.id.rawValue,
            startTime: self.startDate,
            duration: self.durations.dataSource.first(where: {$0.id == self.durations.chosenItemId})?.duration,
            smsNotification: self.sms,
            emailNotification: self.email,
            surveyNotification: self.feedback,
            reminderNotification: self.reminder,
            note: self.note
        )
    }
}

public enum AddAppointmentAction: Equatable {
    case saveAppointmentTap
    case addAppointmentDismissed
    case chooseStartDate(Date)
    case clients(ChooseClientsAction)
    case services(ChooseServiceAction)
    case durations(SingleChoiceLinkAction<Duration>)
    case with(ChooseEmployeesAction)
    case participants(SingleChoiceLinkAction<Employee>)
    case closeBtnTap
    case didTapServices
    case didTapWith
    case didTabClients
    case isAllDay(ToggleAction)
    case sms(ToggleAction)
    case reminder(ToggleAction)
    case email(ToggleAction)
    case feedback(ToggleAction)
    case note(TextChangeAction)
    case appointmentCreated(Result<PlaceholdeResponse, RequestError>)
}

extension Employee: SingleChoiceElement { }
extension Service: SingleChoiceElement { }

let addAppTapBtnReducer = Reducer<AddAppointmentState?,
                                  AddAppointmentAction, AddAppointmentEnv> { state, action, env in
    switch action {
    case .saveAppointmentTap:
        if let appointmentsBody = state?.appointmentsBody {
            state?.showsLoadingSpinner = true

            return env.clientAPI.createAppointment(appointment: appointmentsBody)
                .catchToEffect()
                .map(AddAppointmentAction.appointmentCreated)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        }

    case .closeBtnTap:
        state = nil
    case .didTapServices:
        state?.services.isChooseServiceActive = true
    case .didTabClients:
        state?.clients.isChooseClientsActive = true
    case .didTapWith:
        state?.with.isChooseEmployeesActive = true
    case .appointmentCreated(let result):
        state?.showsLoadingSpinner = false

        switch result {
        case .success(let services):
            state = nil
        case .failure:
            break
        }
    default:
        break
    }
    return .none
}

public let addAppointmentValueReducer: Reducer<AddAppointmentState,
                                               AddAppointmentAction, AddAppointmentEnv> = .combine(
                                                chooseClientsReducer.pullback(
                                                    state: \AddAppointmentState.clients,
                                                    action: /AddAppointmentAction.clients,
                                                    environment: { $0 }),
                                                chooseServiceReducer.pullback(
                                                    state: \AddAppointmentState.services,
                                                    action: /AddAppointmentAction.services,
                                                    environment: { $0 }),
                                                SingleChoiceLinkReducer<Duration>().reducer.pullback(
                                                    state: \AddAppointmentState.durations,
                                                    action: /AddAppointmentAction.durations,
                                                    environment: { $0 }),
                                                chooseEmployeesReducer.pullback(
                                                    state: \AddAppointmentState.with,
                                                    action: /AddAppointmentAction.with,
                                                    environment: { $0 }),
                                                SingleChoiceLinkReducer<Employee>().reducer.pullback(
                                                    state: \AddAppointmentState.participants,
                                                    action: /AddAppointmentAction.participants,
                                                    environment: { $0 }),
                                                switchCellReducer.pullback(
                                                    state: \AddAppointmentState.isAllDay,
                                                    action: /AddAppointmentAction.isAllDay,
                                                    environment: { $0 }),
                                                switchCellReducer.pullback(
                                                    state: \AddAppointmentState.sms,
                                                    action: /AddAppointmentAction.sms,
                                                    environment: { $0 }),
                                                switchCellReducer.pullback(
                                                    state: \AddAppointmentState.reminder,
                                                    action: /AddAppointmentAction.reminder,
                                                    environment: { $0 }),
                                                switchCellReducer.pullback(
                                                    state: \AddAppointmentState.feedback,
                                                    action: /AddAppointmentAction.feedback,
                                                    environment: { $0 }),
                                                switchCellReducer.pullback(
                                                    state: \AddAppointmentState.email,
                                                    action: /AddAppointmentAction.email,
                                                    environment: { $0 }),
                                                textFieldReducer.pullback(
                                                    state: \AddAppointmentState.note,
                                                    action: /AddAppointmentAction.note,
                                                    environment: { $0 }),
												.init { state, action, _ in
													if case let AddAppointmentAction.chooseStartDate(startDate) = action {
														state.startDate = startDate
													}
													return .none
												}
                                               )

public let addAppointmentReducer: Reducer<AddAppointmentState?,
                                          AddAppointmentAction, AddAppointmentEnv> = .combine(
                                            addAppointmentValueReducer.optional.pullback(
                                                state: \AddAppointmentState.self,
                                                action: /AddAppointmentAction.self,
                                                environment: { $0 }),
                                            addAppTapBtnReducer.pullback(
                                                state: \AddAppointmentState.self,
                                                action: /AddAppointmentAction.self,
                                                environment: { $0 })
                                          )

public struct AddAppointment: View {
    @State var isAllDay: Bool = true
    let store: Store<AddAppointmentState, AddAppointmentAction>
    @ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
    public init(store: Store<AddAppointmentState, AddAppointmentAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            SwitchCell(text: "All Day", store: store.scope(state: { $0.isAllDay },
                                                           action: { .isAllDay($0)})
            ).wrapAsSection(title: "Add Appointment")
            AddAppSections(store: self.store)
                .environmentObject(KeyboardFollower())
            AddEventPrimaryBtn(title: Texts.saveAppointment) {
                self.viewStore.send(.saveAppointmentTap)
            }
        }
        .addEventWrapper(onXBtnTap: { self.viewStore.send(.closeBtnTap) })
        .loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
    }
}

struct ClientDaySection: View {
    let store: Store<AddAppointmentState, AddAppointmentAction>
    @ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
    init (store: Store<AddAppointmentState, AddAppointmentAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    var body: some View {
        HStack(spacing: 24.0) {
            TitleAndValueLabel(
                "CLIENT",
                self.viewStore.state.clients.chosenClient?.fullname ??  "Choose client",
                self.viewStore.state.clients.chosenClient?.fullname == nil ? Color.grayPlaceholder : nil
            ).onTapGesture {
                self.viewStore.send(.didTabClients)
            }
            NavigationLink.emptyHidden(
                self.viewStore.state.clients.isChooseClientsActive,
                ChooseClients(
                    store: self.store.scope(
                        state: { $0.clients },
                        action: {.clients($0) }
                    )
                )
            )
			DatePickerControl.init("DAY", viewStore.binding(get: { $0.startDate },
															send: { .chooseStartDate($0!) })
			)
        }
    }
}

struct ServicesDurationSection: View {
    let store: Store<AddAppointmentState, AddAppointmentAction>
    @ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
    init (store: Store<AddAppointmentState, AddAppointmentAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    var body: some View {
        VStack {
            HStack(spacing: 24.0) {
                TitleAndValueLabel(
                    "SERVICE",
                    self.viewStore.state.services.chosenService?.name ?? "Choose Service",
                    self.viewStore.state.services.chosenService?.name == nil ? Color.grayPlaceholder : nil
                ).onTapGesture {
                    self.viewStore.send(.didTapServices)
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.services.isChooseServiceActive,
                    ChooseService(store: self.store.scope(state: { $0.services }, action: {
                        .services($0)
                    }))
                )
                SingleChoiceLink.init(
                    content: {
                        TitleAndValueLabel.init(
                            "DURATION", self.viewStore.state.durations.chosenItemName ?? "")
                    },
                    store: self.store.scope(
                        state: { $0.durations },
                        action: { .durations($0) }
                    ),
                    cell: TextAndCheckMarkContainer.init(state:),
                    title: "Duration"
                )
            }
            HStack(spacing: 24.0) {
                TitleAndValueLabel(
                    "WITH",
                    self.viewStore.state.with.chosenEmployee?.name ?? "Choose Employee",
                    self.viewStore.state.with.chosenEmployee?.name == nil ? Color.grayPlaceholder : nil
                ).onTapGesture {
                    self.viewStore.send(.didTapWith)
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.with.isChooseEmployeesActive,
                    ChooseEmployeesView(
                        store: self.store.scope(state: { $0.with },
                                                action: { .with($0) })
                    )
                )
                SingleChoiceLink.init(
                    content: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.deepSkyBlue)
                                .font(.regular15)
                            Text("Add Participant")
                                .foregroundColor(Color.textFieldAndTextLabel)
                                .font(.semibold15)
                            Spacer()
                        }
                    },
                    store: self.store.scope(
                        state: { $0.participants },
                        action: { .participants($0) }
                    ),
                    cell: TextAndCheckMarkContainer.init(state:),
                    title: "Add Participant"

                )
            }
        }.wrapAsSection(title: "Services")
    }
}

struct AddAppSections: View {
    @EnvironmentObject var keyboardHandler: KeyboardFollower
    let store: Store<AddAppointmentState, AddAppointmentAction>
    @ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
    init (store: Store<AddAppointmentState, AddAppointmentAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            ClientDaySection(store: self.store)
            ServicesDurationSection(store: self.store)
            NotesSection(
                store: store.scope(
                    state: { $0.note },
                    action: { .note($0) }
                )
            )
            Group {
                SwitchCell(text: Texts.sendReminder,
                           store: store.scope(
                            state: { $0.reminder },
                            action: { .reminder($0) })
                )
                SwitchCell(text: Texts.sendConfirmationEmail,
                           store: store.scope(
                            state: { $0.email },
                            action: { .email($0) })
                )
                SwitchCell(text: Texts.sendConfirmationSMS,
                           store: store.scope(
                            state: { $0.sms },
                            action: { .sms($0) })
                )
                SwitchCell(text: Texts.sendFeedbackSurvey,
                           store: store.scope(
                            state: { $0.feedback },
                            action: { .feedback($0) })
                )
            }.switchesSection(title: Texts.communications)
        }.padding(.bottom, keyboardHandler.keyboardHeight)
    }
}

extension Client: SingleChoiceElement {
    public var name: String {
        return firstName + " " + lastName
    }
}

extension AddAppointmentState {

    public init(
        editingAppointment: Appointment? = nil,
        startDate: Date,
        endDate: Date
    ) {
        self.init(
            editingAppointment: editingAppointment,
            reminder: false,
            email: false,
            sms: false,
            feedback: false,
            isAllDay: false,
            clients: ChooseClientsState(
                isChooseClientsActive: false,
                chosenClient: nil
            ),
            startDate: startDate,
            services: ChooseServiceState(
                isChooseServiceActive: false,
                filterChosen: .allStaff
            ),
            durations: AddAppMocks.durationState,
            with: ChooseEmployeesState(isChooseEmployeesActive: false),
            participants: AddAppMocks.participantsState,
            showsLoadingSpinner: false
        )
    }

    public init(
        startDate: Date,
        endDate: Date,
        employee: Employee
    ) {
        var employees = AddAppMocks.withState
        employees.dataSource.append(employee)
        employees.chosenItemId = employee.id
        self.init(
            editingAppointment: nil,
            reminder: false,
            email: false,
            sms: false,
            feedback: false,
            isAllDay: false,
            clients: ChooseClientsState(
                isChooseClientsActive: false,
                chosenClient: nil
            ),
            startDate: startDate,
            services: ChooseServiceState(
                isChooseServiceActive: false,
                filterChosen: .allStaff
            ),
            durations: AddAppMocks.durationState,
            with: ChooseEmployeesState(isChooseEmployeesActive: false),
            participants: AddAppMocks.participantsState,
            showsLoadingSpinner: false
        )
    }

    public static let dummy = AddAppointmentState.init(
        editingAppointment: nil,
        reminder: false,
        email: false,
        sms: false,
        feedback: false,
        isAllDay: false,
        clients: ChooseClientsState(
            isChooseClientsActive: false,
            chosenClient: nil
        ),
        startDate: Date(),
        services: ChooseServiceState(
            isChooseServiceActive: false,
            filterChosen: .allStaff
        ),
        durations: AddAppMocks.durationState,
        with: ChooseEmployeesState(isChooseEmployeesActive: false),
        participants: AddAppMocks.participantsState,
        showsLoadingSpinner: false
    )
}

struct AddAppMocks {
    static let clientState: SingleChoiceLinkState<Client> =
        SingleChoiceLinkState.init(
            dataSource: [
                Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
                Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
            ],
            chosenItemId: 1,
            isActive: false)

    static let serviceState: SingleChoiceLinkState<Service> =
        SingleChoiceLinkState.init(
            dataSource: [
                Service.init(id: "1", name: "Botox", color: "", categoryName: "Injectables"),
                Service.init(id: "2", name: "Fillers", color: "", categoryName: "Urethra"),
                Service.init(id: "3", name: "Facial", color: "", categoryName: "Mosaic")
            ],
            chosenItemId: "1",
            isActive: false)

    static let durationState: SingleChoiceLinkState<Duration> =
        SingleChoiceLinkState.init(
            dataSource: IdentifiedArray(Duration.all),
            chosenItemId: 1,
            isActive: false)

    static let withState: SingleChoiceLinkState<Employee> =
        SingleChoiceLinkState.init(
            dataSource: [

            ],
            chosenItemId: "456",
            isActive: false)

    static let participantsState: SingleChoiceLinkState<Employee> =
        SingleChoiceLinkState.init(
            dataSource: [

            ],
            chosenItemId: "1",
            isActive: false)
}
