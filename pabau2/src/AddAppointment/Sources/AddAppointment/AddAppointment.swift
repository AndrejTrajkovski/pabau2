import SwiftUI
import Model
import ComposableArchitecture
import Util
import Form
import SharedComponents

public typealias AddAppointmentEnv = (journeyAPI: JourneyAPI, clientsAPI: ClientsAPI, userDefaults: UserDefaultsConfig)

public struct AddAppointmentState: Equatable {
    var reminder: Bool
    var email: Bool
    var sms: Bool
    var feedback: Bool
    var isAllDay: Bool
    var clients: SingleChoiceLinkState<Client>
    var startDate: Date
    var services: ChooseServiceState
    var durations: SingleChoiceLinkState<Duration>
    var with: SingleChoiceLinkState<Employee>
    var participants: SingleChoiceLinkState<Employee>
    var note: String = ""
}

public enum AddAppointmentAction: Equatable {
    case saveAppointmentTap
    case addAppointmentDismissed
    case chooseStartDate
    case clients(SingleChoiceLinkAction<Client>)
    case services(ChooseServiceAction)
    case durations(SingleChoiceLinkAction<Duration>)
    case with(SingleChoiceLinkAction<Employee>)
    case participants(SingleChoiceLinkAction<Employee>)
    case closeBtnTap
    case didTapServices
    case isAllDay(ToggleAction)
    case sms(ToggleAction)
    case reminder(ToggleAction)
    case email(ToggleAction)
    case feedback(ToggleAction)
    case note(TextChangeAction)
}

extension Employee: SingleChoiceElement { }
extension Service: SingleChoiceElement { }

let addAppTapBtnReducer = Reducer<AddAppointmentState?,
    AddAppointmentAction, AddAppointmentEnv> { state, action, _ in
        switch action {
        case .saveAppointmentTap:
            state = nil
        case .closeBtnTap:
            state = nil
        case .didTapServices:
            state?.services.isChooseServiceActive = true
        default:
            break
        }
        return .none
}

public let addAppointmentValueReducer: Reducer<AddAppointmentState,
    AddAppointmentAction, AddAppointmentEnv> = .combine(
        SingleChoiceLinkReducer<Client>().reducer.pullback(
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
        SingleChoiceLinkReducer<Employee>().reducer.pullback(
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
            environment: { $0 })
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
        }.addEventWrapper(onXBtnTap: { self.viewStore.send(.closeBtnTap) })
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
            SingleChoiceLink.init(content: {
                TitleAndValueLabel.init("CLIENT", self.viewStore.state.clients.chosenItemName ?? "")
            }, store: self.store.scope(state: { $0.clients },
                                       action: { .clients($0) }),
            cell: TextAndCheckMarkContainer.init(state:)
            )
            TitleAndValueLabel.init("DAY", self.viewStore.state.startDate.toString())
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
                TitleAndValueLabel("SERVICE", self.viewStore.state.services.chosenServiceName).onTapGesture {
                    self.viewStore.send(.didTapServices)
                }
                NavigationLink.emptyHidden(self.viewStore.state.services.isChooseServiceActive,
                                           ChooseService(store: self.store.scope(state: { $0.services }, action: {
                                            .services($0)
                                           }))
                )
                SingleChoiceLink.init(content: {
                    TitleAndValueLabel.init("DURATION", self.viewStore.state.durations.chosenItemName ?? "")
                }, store: self.store.scope(state: { $0.durations },
                                           action: { .durations($0) }),
                cell: TextAndCheckMarkContainer.init(state:)
                )
            }
            HStack(spacing: 24.0) {
                SingleChoiceLink.init(content: {
                    LabelHeartAndTextField.init("WITH", self.viewStore.state.with.chosenItemName ?? "",
                                                true)
                }, store: self.store.scope(state: { $0.with },
                                           action: { .with($0) }),
                cell: TextAndCheckMarkContainer.init(state:)
                )
                SingleChoiceLink.init(content: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.deepSkyBlue)
                            .font(.regular15)
                        Text("Add Participant")
                            .foregroundColor(Color.textFieldAndTextLabel)
                            .font(.semibold15)
                        Spacer()
                    }
                }, store: self.store.scope(state: { $0.participants },
                                           action: { .participants($0) }),
                cell: TextAndCheckMarkContainer.init(state:)
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
            NotesSection(store: store.scope(state: { $0.note },
                                            action: { .note($0) }))
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

    public init(startDate: Date,
                endDate: Date) {
        self.init(
            reminder: false,
            email: false,
            sms: false,
            feedback: false,
            isAllDay: false,
            clients: AddAppMocks.clientState,
            startDate: startDate,
            services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
            durations: AddAppMocks.durationState,
            with: AddAppMocks.withState,
            participants: AddAppMocks.participantsState
        )
    }

    public init(startDate: Date,
                endDate: Date,
                employee: Employee) {
        var employees = AddAppMocks.withState
        employees.dataSource.append(employee)
        employees.chosenItemId = employee.id
        self.init(
            reminder: false,
            email: false,
            sms: false,
            feedback: false,
            isAllDay: false,
            clients: AddAppMocks.clientState,
            startDate: startDate,
            services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
            durations: AddAppMocks.durationState,
            with: employees,
            participants: AddAppMocks.participantsState
        )
    }

    public static let dummy = AddAppointmentState.init(
        reminder: false,
        email: false,
        sms: false,
        feedback: false,
        isAllDay: false,
        clients: AddAppMocks.clientState,
        startDate: Date(),
        services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
        durations: AddAppMocks.durationState,
        with: AddAppMocks.withState,
        participants: AddAppMocks.participantsState
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
                Service.init(id: 1, name: "Botox", color: "", categoryId: 1, categoryName: "Injectables"),
                Service.init(id: 2, name: "Fillers", color: "", categoryId: 2, categoryName: "Urethra"),
                Service.init(id: 3, name: "Facial", color: "", categoryId: 3, categoryName: "Mosaic")
            ],
            chosenItemId: 1,
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
