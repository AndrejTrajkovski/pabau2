import ComposableArchitecture
import Model
import SharedComponents
import ChooseLocationAndEmployee
import ToastAlert

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
			
			guard let shiftSheme = state?.shiftSchema else {
				break
			}
			
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
                state?.toast = ToastState(mode: .alert,
                                         type: .error(.red),
                                         title: error.description)
                return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                    .map { _ in AddShiftAction.dismissToast }
			}
        case .dismissToast:
            state?.toast = nil
            return .cancel(id: ToastTimerId())
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
		.init { state, action, _ in
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
            case .dismissToast:
                break
			}
			return .none
		}
	)
