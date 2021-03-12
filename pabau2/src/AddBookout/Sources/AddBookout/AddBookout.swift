import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

public typealias AddBookoutEnvironment = (apiClient: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig)

public let addBookoutOptReducer: Reducer<
    AddBookoutState?,
    AddBookoutAction,
    AddBookoutEnvironment
> = .combine(
    addBookoutReducer.optional.pullback(
        state: \.self,
        action: /AddBookoutAction.self,
        environment: { $0 }
    ),
    .init { state, action, env in
        switch action {
        case .saveBookout:
            guard let appointmentsBody =  state?.appointmentsBody  else {
                break
            }

            var isValid = true

            if state?.chooseEmployeesState.chosenEmployee?.name == nil {
                state?.employeeConfigurator.state = .error

                isValid = false
            }

            if !isValid { break }

            state?.showsLoadingSpinner = true

            return env.clientAPI.createAppointment(appointment: appointmentsBody)
                .catchToEffect()
                .map(AddBookoutAction.appointmentCreated)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        case .appointmentCreated(let result):
            state?.showsLoadingSpinner = false
            switch result {
            case .success:
                state = nil
            case .failure:
                break
            }
        default:
            break
        }
        return .none
    }
)

public let addBookoutReducer: Reducer<
    AddBookoutState,
    AddBookoutAction,
    AddBookoutEnvironment
> = .combine(
    SingleChoiceReducer<Duration>().reducer.pullback(
        state: \.chooseDuration,
        action: /AddBookoutAction.chooseDuration,
        environment: { $0 }
    ),
    textFieldReducer.pullback(
        state: \.note,
        action: /AddBookoutAction.note,
        environment: { $0 }),
    textFieldReducer.pullback(
        state: \.description,
        action: /AddBookoutAction.description,
        environment: { $0 }),
    switchCellReducer.pullback(
        state: \.isPrivate,
        action: /AddBookoutAction.isPrivate,
        environment: { $0 }
    ),
    chooseEmployeesReducer.pullback(
        state: \AddBookoutState.chooseEmployeesState,
        action: /AddBookoutAction.chooseEmployeesAction,
        environment: { $0 }
    ),
    switchCellReducer.pullback(
        state: \.isAllDay,
        action: /AddBookoutAction.isAllDay,
        environment: { $0 }
    ),
    .init { state, action, env in
        switch action {
        case .chooseStartDate(let day):
            guard let day = day else {
                break
            }
            state.startDate = day
        case .chooseTime(let time):
            state.timeConfigurator.state = .normal
            state.time = time
        case .onChooseEmployee:
            state.chooseEmployeesState.isChooseEmployeesActive = true
            state.employeeConfigurator.state = .normal
        default:
            break
        }
        return .none
   }
)

public struct AddBookoutState: Equatable {
    var editingBookout: Bookout?
	var chooseEmployee: SingleChoiceLinkState<Employee>
	var chooseDuration: SingleChoiceState<Duration>
    var chooseEmployeesState: ChooseEmployeesState
    var startDate: Date
    var time: Date?
	var description: String = ""
	var note: String = ""
    var isPrivate: Bool = false
	var isAllDay: Bool = false

    var showsLoadingSpinner: Bool = false

    var employeeConfigurator = ViewConfigurator(errorString: "Employee is required")
    var dayConfigurator = ViewConfigurator(errorString: "Day is required")
    var timeConfigurator = ViewConfigurator(errorString: "Time is required")
    var durationConfigurator = ViewConfigurator(errorString: "Duration is required")

    var appointmentsBody: AppointmentBuilder {
        return AppointmentBuilder(
            isAllDay: self.isAllDay,
            isPrivate: self.isPrivate,
            employeeID: self.chooseEmployeesState.chosenEmployee?.id.rawValue,
            startTime: self.startDate,
            duration: self.chooseDuration.dataSource.first(where: {$0.id == self.chooseDuration.chosenItemId})?.duration,
            note: self.note,
            description: self.description
        )
    }
}

public enum AddBookoutAction {
    case chooseStartDate(Date?)
    case chooseTime(Date?)
    case chooseEmployeesAction(ChooseEmployeesAction)
    case onChooseEmployee
	case chooseDuration(SingleChoiceActions<Duration>)
	case isPrivate(ToggleAction)
	case isAllDay(ToggleAction)
	case note(TextChangeAction)
	case description(TextChangeAction)
	case close
	case saveBookout
    case appointmentCreated(Result<PlaceholdeResponse, RequestError>)
    case ignore
}

extension Employee: SingleChoiceElement {}

public struct AddBookout: View {
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	public init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	public var body: some View {
		VStack {
            FirstSection(store: store)
			DateAndTime(store: store)
			DescriptionAndNotes(store: store)
			AddEventPrimaryBtn(title: "Save Bookout") {
				viewStore.send(.saveBookout)
			}
		}
        .addEventWrapper(onXBtnTap: { viewStore.send(.close) })
        .loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
	}
}

struct FirstSection: View {
    let store: Store<AddBookoutState, AddBookoutAction>
    @ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

    init(store: Store<AddBookoutState, AddBookoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Buttons().isHidden(true, remove: true)
                SwitchCell(
                    text: Texts.allDay,
                    store: store.scope(
                        state: { $0.isAllDay },
                        action: { .isAllDay($0)}
                    )
                )
                TitleAndValueLabel(
                    "EMPLOYEE",
                    self.viewStore.state.chooseEmployeesState.chosenEmployee?.name ?? "Choose Employee",
                    self.viewStore.state.chooseEmployeesState.chosenEmployee?.name == nil ? Color.grayPlaceholder : nil,
                    viewStore.binding(
                        get: { $0.employeeConfigurator },
                        send: .ignore
                    )
                ).onTapGesture {
                    self.viewStore.send(.onChooseEmployee)
                }
                NavigationLink.emptyHidden(
                    self.viewStore.state.chooseEmployeesState.isChooseEmployeesActive,
                    ChooseEmployeesView(
                        store: self.store.scope(
                            state: { $0.chooseEmployeesState },
                            action: { .chooseEmployeesAction($0) }
                        )
                    )
                )
            }.wrapAsSection(title: "Add Bookout")
        }
    }
}

struct DateAndTime: View {
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack(spacing: 16) {
			HStack {
                DatePickerControl.init(
                    "DAY",
                    viewStore.binding(
                        get: { $0.startDate },
                        send: { .chooseStartDate($0) }
                    ),
                    viewStore.binding(
                        get: { $0.dayConfigurator },
                        send: .ignore
                    )
                ).isHidden(!viewStore.isAllDay, remove: true)

                DatePickerControl.init(
                    "DAY",
                    viewStore.binding(
                        get: { $0.startDate },
                        send: { .chooseStartDate($0) }
                    ),
                    viewStore.binding(
                        get: { $0.dayConfigurator },
                        send: .ignore
                    ),
                    mode: .dateAndTime
                ).isHidden(viewStore.isAllDay, remove: true)

//                DatePickerControl.init(
//                    "TIME",
//                    viewStore.binding(
//                        get: { $0.time },
//                        send: { .chooseTime($0) }
//                    ),
//                    viewStore.binding(
//                        get: { $0.timeConfigurator },
//                        send: .ignore
//                    ),
//                    mode: .time
//                )
//                .isHidden(
//                    viewStore.state.isAllDay
//                )
			}
			GeometryReader { geo in
				HStack {
					TitleAndValueLabel(
                        "DURATION",
                        self.viewStore.state.chooseDuration.chosenItemName ?? "",
                        nil,
                        viewStore.binding(
                            get: { $0.durationConfigurator },
                            send: .ignore
                        )
					)
                    .frame(width: geo.size.width / 2)
					DurationPicker(
                        store: store.scope(
                            state: { $0.chooseDuration },
                            action: { .chooseDuration($0) }
                        )
                    )
                    .frame(maxWidth: .infinity)
				}
			}
		}.wrapAsSection(title: "Date & Time")
	}
}

struct DescriptionAndNotes: View {

	let store: Store<AddBookoutState, AddBookoutAction>

	public init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
	}

	var body: some View {
		VStack(spacing: 16) {
			TitleAndTextField(
                title: "DESCRIPTION",
				tfLabel: "Add description.",
				store: store.scope(
                    state: { $0.description },
					action: { .description($0) }
                )
			)
			TitleAndTextField(
                title: "NOTE",
				tfLabel: "Add a note.",
				store: store.scope(
                    state: { $0.note },
					action: { .note($0)}
                )
			)
			SwitchCell(
                text: "Private Bookout",
				store: store.scope(
                    state: { $0.isPrivate },
					action: { .isPrivate($0) }
                )
			)
		}.wrapAsSection(title: "Description & Notes")
	}
}

extension AddBookoutState {
	public init(
        employees: IdentifiedArrayOf<Employee>,
		chosenEmployee: Employee.ID?,
        start: Date
    ) {
        self.init(
            chooseEmployee: SingleChoiceLinkState.init(
                dataSource: employees,
                chosenItemId: chosenEmployee,
                isActive: false
            ),
            chooseDuration:
                SingleChoiceState<Duration>(
                    dataSource: IdentifiedArray.init(Duration.all),
                    chosenItemId: nil
                ),
            chooseEmployeesState: ChooseEmployeesState(isChooseEmployeesActive: false),
            startDate: start,
            time: nil,
            description: "",
            note: "",
            isPrivate: false
        )
    }
    public init(
        employees: IdentifiedArrayOf<Employee>,
        chosenEmployee: Employee.ID?,
        start: Date,
        bookout: Bookout
    ) {
        self.init(
            chooseEmployee: SingleChoiceLinkState.init(
                dataSource: employees,
                chosenItemId: chosenEmployee,
                isActive: false
            ),
            chooseDuration:
                SingleChoiceState<Duration>(
                    dataSource: IdentifiedArray.init(Duration.all),
                    chosenItemId: nil
                ),
            chooseEmployeesState: ChooseEmployeesState(isChooseEmployeesActive: false),
            startDate: bookout.start_date,
            time: nil,
            description: bookout._description ?? "",
            note: "",
            isPrivate: bookout._private ?? false
        )
    }
}
