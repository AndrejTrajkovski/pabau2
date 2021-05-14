import SwiftUI
import ComposableArchitecture
import SharedComponents
import Model
import Util
import CoreDataModel

public let addShiftOptReducer: Reducer<
    AddShiftState?,
    AddShiftAction,
    AddShiftEnvironment
> = .combine(
    addShiftReducer.optional().pullback(
        state: \.self,
        action: /AddShiftAction.self,
        environment: { $0 }
    ),
    .init { state, action, env in
        switch action {
        case .close:
            state = nil
        case .saveShift:
            guard let shiftSheme = state?.shiftSchema else {
                break
            }

            var isValid = true

            if state?.startTime == nil {
                isValid = false
                state?.startTimeConfigurator.state = .error
            }

            if state?.endTime == nil {
                isValid = false
                state?.endTimeConfigurator.state = .error
            }

            if state?.chooseEmployeesState.chosenEmployee?.name == nil {
                isValid = false
                state?.employeeConfigurator.state = .error
            }

            if !isValid { break }

            state?.showsLoadingSpinner = true

            return env.apiClient.createShift(
                shiftSheme: shiftSheme
            )
            .catchToEffect()
            .receive(on: DispatchQueue.main)
            .map(AddShiftAction.shiftCreated)
            .eraseToEffect()
        case .shiftCreated(let result):
            state?.showsLoadingSpinner = false

            switch result {
            case .success:
                state = nil
            case .failure(let error):
                print(error)
            }
        default: break
        }
        return .none
    }
)

public let addShiftReducer: Reducer<AddShiftState, AddShiftAction, AddShiftEnvironment> =
	.combine(
		switchCellReducer.pullback(
			state: \.isPublished,
			action: /AddShiftAction.isPublished,
			environment: { $0 }
		),
        chooseEmployeesReducer.pullback(
            state: \AddShiftState.chooseEmployeesState,
            action: /AddShiftAction.chooseEmployee,
            environment: { $0 }),
        chooseLocationsReducer.pullback(
            state: \AddShiftState.chooseLocationState,
            action: /AddShiftAction.chooseLocation,
            environment: { $0 }),
		textFieldReducer.pullback(
			state: \.note,
			action: /AddShiftAction.note,
			environment: { $0 }),
		.init { state, action, env in
			switch action {
            case .isPublished(.setTo(let isOn)):
                state.isPublished = isOn
			case .startDate(let date):
				state.startDate = date
			case .startTime(let date):
				state.startTime = date
                state.startTimeConfigurator.state = .normal
			case .endTime(let date):
				state.endTime = date
                state.endTimeConfigurator.state = .normal
            case .note(.textChange(let text)):
                state.note = text
            case .onChooseEmployee:
                state.chooseEmployeesState.isChooseEmployeesActive = true
                state.employeeConfigurator.state = .normal
            case .onChooseLocation:
                state.chooseLocationState.isChooseLocationActive = true
			default: break
			}
			return .none
		}
	)

public struct AddShiftState: Equatable {
    var shiftRotaID: Int?
	var isPublished: Bool = false
    var chooseEmployeesState: ChooseEmployeesState
	var chooseLocationState: ChooseLocationState
	var startDate: Date?
	var startTime: Date?
	var endTime: Date?
	var note: String

    var showsLoadingSpinner: Bool = false
    var employeeConfigurator = ViewConfigurator(errorString: "Employee is required")
    var startTimeConfigurator = ViewConfigurator(errorString: "Start Time is required")
    var endTimeConfigurator = ViewConfigurator(errorString: "End Time is required")

    var shiftSchema: ShiftSchema {
        let rotaUID = chooseEmployeesState.chosenEmployee?.id.rawValue
        let locationID = chooseLocationState.chosenLocation?.id.rawValue

        return ShiftSchema(
            rotaID: shiftRotaID,
            date: startDate?.getFormattedDate(format: "yyyy-dd-MM"),
            startTime: endTime?.getFormattedDate(format: "HH:mm"),
            endTime: startTime?.getFormattedDate(format: "HH:mm"),
            locationID: "\(locationID)",
            notes: note,
            published: isPublished,
            rotaUID: rotaUID
        )
    }
}

public enum AddShiftAction {
	case isPublished(ToggleAction)
    case chooseEmployee(ChooseEmployeesAction)
	case chooseLocation(ChooseLocationAction)
    case onChooseEmployee
    case onChooseLocation
    case shiftCreated(Result<PlaceholdeResponse, RequestError>)
	case startDate(Date?)
	case startTime(Date?)
	case endTime(Date?)
	case note(TextChangeAction)
	case saveShift
	case close
    case ignore
}

public struct AddShift: View {

	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>

	public var body: some View {
        VStack {
            VStack(spacing: 24) {
                SwitchCell(
                    text: "Published",
                    store: store.scope(
                        state: { $0.isPublished },
                        action: { .isPublished($0)}
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
                            action: { .chooseEmployee($0) }
                        )
                    )
                )
            }.wrapAsSection(title: "Add Shift")
            LocationAndDate(store: store).wrapAsSection(title: "Date & Time")
            NotesSection(
                title: "SHIFT NOTE",
                tfLabel: "Add a shift note",
                store: store.scope(
                    state: { $0.note },
                    action: { .note($0)}
                )
            )
            AddEventPrimaryBtn(title: "Save Shift") {
                self.viewStore.send(.saveShift)
            }
        }
        .addEventWrapper(onXBtnTap: { viewStore.send(.close) })
        .loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
	}

	public init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

struct LocationAndDate: View {

	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>

	var body: some View {
		VStack(spacing: 16) {
			HStack(spacing: 16) {
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
				DatePickerControl(
                    "Day",
                    viewStore.binding(
                        get: { $0.startDate },
					    send: { .startDate($0) }
                    )
				)
			}
			HStack(spacing: 16) {
				DatePickerControl(
                    "START TIME",
					viewStore.binding(
                        get: { $0.startTime },
                        send: { .startTime($0) }
                    ),
                    viewStore.binding(
                        get: { $0.startTimeConfigurator },
                        send: AddShiftAction.ignore
                    ),
                    mode: .time
                )
				DatePickerControl(
                    "END TIME",
					viewStore.binding(
                        get: { $0.endTime },
                        send: { .endTime($0) }
                    ),
                    viewStore.binding(
                        get: { $0.endTimeConfigurator },
                        send: AddShiftAction.ignore
                    ),
                    mode: .time
                )
			}
		}
	}

	init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

extension Employee: SingleChoiceElement { }
extension Location: SingleChoiceElement { }

public typealias AddShiftEnvironment = (apiClient: JourneyAPI, clientAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

extension AddShiftState {
	public static func makeEmpty() -> AddShiftState {
		AddShiftState(
            shiftRotaID: nil,
            isPublished: true,
			chooseEmployeesState: ChooseEmployeesState(chosenEmployee: nil),
            chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
            startDate: nil,
            startTime: nil,
            endTime: nil,
            note: ""
        )
	}
    public static func makeEditing(shift: Shift) -> AddShiftState {
        AddShiftState(
            shiftRotaID: shift.rotaID,
            isPublished: shift.published ?? false,
			chooseEmployeesState: ChooseEmployeesState(chosenEmployee: nil),
            chooseLocationState: ChooseLocationState(isChooseLocationActive: false),
            startDate: shift.date,
            startTime: shift.startTime,
            endTime: shift.endTime,
            note: shift.notes
        )
    }
}
