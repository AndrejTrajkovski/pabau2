import SwiftUI
import ComposableArchitecture
import SharedComponents
import Model
import Util
import CoreDataModel
import ChooseLocationAndEmployee

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
				state?.startTimeValidator = "Start Time is required."
			}
			
			if state?.endTime == nil {
				isValid = false
				state?.endTimeValidator = "End Time is required."
			}
			
			if state?.chooseLocAndEmp.chosenEmployeeId == nil {
				isValid = false
				state?.chooseLocAndEmp.employeeValidationError = "Employee is required."
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
		chooseLocationAndEmployeeReducer.pullback(
			state: \AddShiftState.chooseLocAndEmp,
			action: /AddShiftAction.chooseLocAndEmp,
			environment: makeChooseLocAndEmpEnv(_:)),
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
				state.startTimeValidator = nil
			case .endTime(let date):
				state.endTime = date
				state.endTimeValidator = nil
			case .note(.textChange(let text)):
				state.note = text
			case .chooseLocAndEmp(_):
				break
			case .shiftCreated(_):
				break
			case .saveShift:
				break
			case .close:
				break
			}
			return .none
		}
	)

public struct AddShiftState: Equatable {
	
	public init(shiftRotaID: Int? = nil, isPublished: Bool = false, chooseLocAndEmp: ChooseLocationAndEmployeeState, startDate: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, note: String, showsLoadingSpinner: Bool = false, employeeValidator: String? = nil, startTimeValidator: String? = nil, endTimeValidator: String? = nil) {
		self.shiftRotaID = shiftRotaID
		self.isPublished = isPublished
		self.chooseLocAndEmp = chooseLocAndEmp
		self.startDate = startDate
		self.startTime = startTime
		self.endTime = endTime
		self.note = note
		self.showsLoadingSpinner = showsLoadingSpinner
		self.startTimeValidator = startTimeValidator
		self.endTimeValidator = endTimeValidator
	}
	
	var shiftRotaID: Int?
	var isPublished: Bool = false
	var chooseLocAndEmp: ChooseLocationAndEmployeeState
	var startDate: Date?
	var startTime: Date?
	var endTime: Date?
	var note: String
	
	var showsLoadingSpinner: Bool = false
	var startTimeValidator: String?
	var endTimeValidator: String?
	
	var shiftSchema: ShiftSchema {
		let rotaUID = chooseLocAndEmp.chosenEmployeeId
		let locationID = chooseLocAndEmp.chosenLocationId
		
		return ShiftSchema(
			rotaID: shiftRotaID,
			date: startDate?.getFormattedDate(format: "yyyy-dd-MM"),
			startTime: endTime?.getFormattedDate(format: "HH:mm"),
			endTime: startTime?.getFormattedDate(format: "HH:mm"),
			locationID: "\(locationID)",
			notes: note,
			published: isPublished,
			rotaUID: rotaUID?.rawValue
		)
	}
}

public enum AddShiftAction {
	case isPublished(ToggleAction)
	case chooseLocAndEmp(ChooseLocationAndEmployeeAction)
	case shiftCreated(Result<PlaceholdeResponse, RequestError>)
	case startDate(Date?)
	case startTime(Date?)
	case endTime(Date?)
	case note(TextChangeAction)
	case saveShift
	case close
}

public struct AddShift: View {
	
	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>
	
	public var body: some View {
		VStack {
			SwitchCell(
				text: "Published",
				store: store.scope(
					state: { $0.isPublished },
					action: { .isPublished($0)}
				))
				.wrapAsSection(title: "Add Shift")
			ChooseLocationAndEmployee(store:
										store.scope(state: { $0.chooseLocAndEmp },
													action: { .chooseLocAndEmp($0) })
			)
			DateAndTime(store: store)
				.wrapAsSection(title: "Date & Time")
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
			Spacer()
		}
		.addEventWrapper(onXBtnTap: { viewStore.send(.close) })
		.loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
	}
	
	public init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

struct DateAndTime: View {
	
	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>
	
	var body: some View {
		VStack(spacing: 16) {
			HStack(spacing: 16) {
				DatePickerControl(
					"Day",
					viewStore.binding(
						get: { $0.startDate },
						send: { .startDate($0) }
					), .constant(nil)
				)
			}
			HStack(spacing: 16) {
				DatePickerControl(
					"START TIME",
					viewStore.binding(
						get: { $0.startTime },
						send: { .startTime($0) }
					),
					.constant(viewStore.startTimeValidator),
					mode: .time
				)
				DatePickerControl(
					"END TIME",
					viewStore.binding(
						get: { $0.endTime },
						send: { .endTime($0) }
					),
					.constant(viewStore.endTimeValidator),
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

extension AddShiftState {
	
	public static func makeEmpty(chooseLocAndEmp: ChooseLocationAndEmployeeState) -> AddShiftState {
		AddShiftState(
			shiftRotaID: nil,
			isPublished: true,
			chooseLocAndEmp: chooseLocAndEmp,
			startDate: nil,
			startTime: nil,
			endTime: nil,
			note: ""
		)
	}
	
	public static func makeEditing(shift: Shift,
								   chooseLocAndEmp: ChooseLocationAndEmployeeState
	) -> AddShiftState {
		AddShiftState(
			shiftRotaID: shift.rotaID,
			isPublished: shift.published ?? false,
			chooseLocAndEmp: chooseLocAndEmp,
			startDate: shift.date,
			startTime: shift.startTime,
			endTime: shift.endTime,
			note: shift.notes
		)
	}
}
