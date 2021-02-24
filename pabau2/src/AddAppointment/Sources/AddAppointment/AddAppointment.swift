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
    var startDate: Date
    var note: String = ""

    var durations: SingleChoiceLinkState<Duration>
    var participants: ChooseParticipantState
    var chooseLocationState: ChooseLocationState
    var with: ChooseEmployeesState
    var services: ChooseServiceState
    var clients: ChooseClientsState

    var employeeConfigurator = ViewConfigurator(errorString: "Employee is required")
    var chooseClintConfigurator = ViewConfigurator(errorString: "Client is required")
    var chooseDateConfigurator = ViewConfigurator(errorString: "Day is required")
    var chooseServiceConfigurator = ViewConfigurator(errorString: "Service is required")

    var showsLoadingSpinner: Bool
    var alertBody: AlertBody?

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
            note: self.note,
            participantUserIDS: self.participants.chosenParticipants.compactMap { $0.id.rawValue }
        )
    }
}

public enum AddAppointmentAction: Equatable {
    case saveAppointmentTap
    case addAppointmentDismissed
    case chooseStartDate(Date)
    case clients(ChooseClientsAction)
    case services(ChooseServiceAction)
    case participants(ChooseParticipantAction)
    case durations(SingleChoiceLinkAction<Duration>)
    case with(ChooseEmployeesAction)
    case chooseLocation(ChooseLocationAction)
    case onChooseLocation
    case didTapParticipants
    case closeBtnTap
    case didTapServices
    case didTapWith
    case didTabClients
    case removeChosenParticipant
    case isAllDay(ToggleAction)
    case sms(ToggleAction)
    case reminder(ToggleAction)
    case email(ToggleAction)
    case feedback(ToggleAction)
    case note(TextChangeAction)
    case appointmentCreated(Result<PlaceholdeResponse, RequestError>)
    case cancelAlert
    case ignore
}

extension Employee: SingleChoiceElement { }
extension Service: SingleChoiceElement { }

let addAppTapBtnReducer = Reducer<
    AddAppointmentState?,
    AddAppointmentAction,
    AddAppointmentEnv
> { state, action, env in
    switch action {
    case .saveAppointmentTap:
        if let appointmentsBody = state?.appointmentsBody {
            var isValid = true

            if state?.clients.chosenClient?.fullname == nil {
                state?.chooseClintConfigurator.state = .error

                isValid = false
            }

            if state?.services.chosenService?.name == nil {
                state?.chooseServiceConfigurator.state = .error

                isValid = false
            }

            if state?.with.chosenEmployee?.name == nil {
                state?.employeeConfigurator.state = .error

                isValid = false
            }

            if !isValid { break }

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
        state?.chooseServiceConfigurator.state = .normal
    case .didTabClients:
        state?.clients.isChooseClientsActive = true
        state?.chooseClintConfigurator.state = .normal
    case .didTapWith:
        state?.with.isChooseEmployeesActive = true
        state?.employeeConfigurator.state = .normal
    case .didTapParticipants:
        guard let isAllDay = state?.isAllDay,
              let location = state?.chooseLocationState.chosenLocation,
              let service = state?.services.chosenService,
              let employee = state?.with.chosenEmployee
        else {
            state?.alertBody = AlertBody(
                title: "Info",
                subtitle: "Please choose Service, Location and Employee",
                primaryButtonTitle: "",
                secondaryButtonTitle: "Ok",
                isShow: true
            )
            break
        }

        state?.participants.participantSchema = ParticipantSchema(
            id: UUID(),
            isAllDays: isAllDay,
            location: location,
            service: service,
            employee: employee
        )

        state?.participants.isChooseParticipantActive = true
    case .onChooseLocation:
        state?.chooseLocationState.isChooseLocationActive = true
    case .removeChosenParticipant:
        state?.participants.chosenParticipants = []
    case .appointmentCreated(let result):
        state?.showsLoadingSpinner = false
        switch result {
        case .success(let services):
            state = nil
        case .failure:
            break
        }
    case .cancelAlert:
        state?.alertBody = nil
    default:
        break
    }
    return .none
}

public let addAppointmentValueReducer: Reducer<
    AddAppointmentState,
    AddAppointmentAction,
    AddAppointmentEnv
> = .combine(
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
        chooseLocationsReducer.pullback(
            state: \AddAppointmentState.chooseLocationState,
            action: /AddAppointmentAction.chooseLocation,
            environment: { $0 }),
        chooseParticipantReducer.pullback(
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

public let addAppointmentReducer: Reducer<
    AddAppointmentState?,
    AddAppointmentAction,
    AddAppointmentEnv
> = .combine(
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
            SwitchCell(
                text: "All Day",
                store: store.scope(
                    state: { $0.isAllDay },
                    action: { .isAllDay($0)}
                )
            ).wrapAsSection(title: "Add Appointment")
            AddAppSections(store: self.store)
                .environmentObject(KeyboardFollower())
            AddEventPrimaryBtn(title: Texts.saveAppointment) {
                self.viewStore.send(.saveAppointmentTap)
            }
        }
        .addEventWrapper(onXBtnTap: { self.viewStore.send(.closeBtnTap) })
        .loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
        .alert(
            isPresented: viewStore.binding(
                get: { $0.alertBody?.isShow == true },
                send: .cancelAlert
            )
        ) {
            Alert(
                title: Text(self.viewStore.state.alertBody?.title ?? ""),
                message: Text(self.viewStore.state.alertBody?.subtitle ?? ""),
                dismissButton: .default(
                    Text(self.viewStore.state.alertBody?.secondaryButtonTitle ?? ""),
                    action: {
                        self.viewStore.send(.cancelAlert)
                    }
                )
            )
        }
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
                self.viewStore.state.clients.chosenClient?.fullname == nil ? Color.grayPlaceholder : nil,
                viewStore.binding(
                    get: { $0.chooseClintConfigurator },
                    send: .ignore
                )
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
            DatePickerControl.init(
                "DAY", viewStore.binding(
                    get: { $0.startDate },
                    send: { .chooseStartDate($0!) }
                )
            ).isHidden(!viewStore.isAllDay, remove: true)

            DatePickerControl.init(
                "DAY", viewStore.binding(
                    get: { $0.startDate },
                    send: { .chooseStartDate($0!) }
                ),
                nil,
                mode: .dateAndTime
            ).isHidden(viewStore.isAllDay, remove: true)
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
                    self.viewStore.state.services.chosenService?.name == nil ? Color.grayPlaceholder : nil,
                    viewStore.binding(
                        get: { $0.chooseServiceConfigurator },
                        send: .ignore
                    )
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
                    self.viewStore.state.with.chosenEmployee?.name == nil ? Color.grayPlaceholder : nil,
                    viewStore.binding(
                        get: { $0.employeeConfigurator },
                        send: .ignore
                    )
                ).onTapGesture {
                    self.viewStore.send(.didTapWith)
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.with.isChooseEmployeesActive,
                    ChooseEmployeesView(
                        store: self.store.scope(
                            state: { $0.with },
                            action: { .with($0) }
                        )
                    )
                )
                TitleAndValueLabel(
                    "LOCATION",
                    self.viewStore.state.chooseLocationState.chosenLocation?.name ?? "Choose Location",
                    self.viewStore.state.chooseLocationState.chosenLocation?.name == nil ? Color.grayPlaceholder : nil
                ).onTapGesture {
                    self.viewStore.send(.onChooseLocation)
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.chooseLocationState.isChooseLocationActive,
                    ChooseLocationView(
                        store: self.store.scope(
                            state: { $0.chooseLocationState },
                            action: { .chooseLocation($0) }
                        )
                    )
                )
                HStack {
                    PlusTitleView()
                        .onTapGesture {
                        self.viewStore.send(.didTapParticipants)
                    }.isHidden(
                        !self.viewStore.state.participants.chosenParticipants.isEmpty,
                        remove: true
                    )
                    TitleMinusView(
                        title: "\(self.viewStore.state.participants.chosenParticipants.first?.fullName ?? "")..."
                    ).onTapGesture {
                        self.viewStore.send(.removeChosenParticipant)
                    }.isHidden(
                        self.viewStore.state.participants.chosenParticipants.isEmpty,
                        remove: true
                    )
                    Spacer()
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.participants.isChooseParticipantActive,
                    ChooseParticipantView(
                        store: self.store.scope(
                            state: { $0.participants },
                            action: { .participants($0) }
                        )
                    )
                )
            }
        }.wrapAsSection(title: "Services")
    }
}

struct PlusTitleView: View {
    var body: some View {
        Image(systemName: "plus.circle")
            .foregroundColor(.deepSkyBlue)
            .font(.regular15)
        Text("Add Participant")
            .foregroundColor(Color.textFieldAndTextLabel)
            .font(.semibold15)
    }
}
struct TitleMinusView: View {
    let title: String?

    var body: some View {
        Text(title ?? "")
            .foregroundColor(Color.textFieldAndTextLabel)
            .font(.semibold15)
        Image(systemName: "minus.circle")
            .foregroundColor(.red)
            .font(.regular15)
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
                title: "BOOKING NOTE",
                tfLabel: "Add a booking note",
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
            editingAppointment: nil,
            reminder: false,
            email: false,
            sms: false,
            feedback: false,
            isAllDay: false,
            startDate: startDate,
            durations: AddAppMocks.durationState,
            participants: ChooseParticipantState(isChooseParticipantActive: false),
            chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
            with: ChooseEmployeesState(isChooseEmployeesActive: false),
            services: ChooseServiceState(
                isChooseServiceActive: false,
                filterChosen: .allStaff
            ),
            clients: ChooseClientsState(
                isChooseClientsActive: false,
                chosenClient: nil
            ),
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
            startDate: startDate,
            durations: AddAppMocks.durationState,
            participants: ChooseParticipantState(isChooseParticipantActive: false),
            chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
            with: ChooseEmployeesState(isChooseEmployeesActive: false),
            services: ChooseServiceState(
                isChooseServiceActive: false,
                filterChosen: .allStaff
            ),
            clients: ChooseClientsState(
                isChooseClientsActive: false,
                chosenClient: nil
            ),
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
        startDate: Date(),
        durations: AddAppMocks.durationState,
        participants: ChooseParticipantState(isChooseParticipantActive: false),
        chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
        with: ChooseEmployeesState(isChooseEmployeesActive: false),
        services: ChooseServiceState(
            isChooseServiceActive: false,
            filterChosen: .allStaff
        ),
        clients: ChooseClientsState(
            isChooseClientsActive: false,
            chosenClient: nil
        ),
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
