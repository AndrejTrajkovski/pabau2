import ComposableArchitecture
import Model
import SharedComponents

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
				.receive(on: DispatchQueue.main)
				.map(AddAppointmentAction.appointmentCreated)
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

let addAppointmentValueReducer: Reducer<
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
			environment: { ChooseLocationEnvironment(
				repository: $0.repository,
				userDefaults: $0.userDefaults
			)
		}),
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
	addAppointmentValueReducer.optional().pullback(
		state: \AddAppointmentState.self,
		action: /AddAppointmentAction.self,
		environment: { $0 }),
	addAppTapBtnReducer.pullback(
		state: \AddAppointmentState.self,
		action: /AddAppointmentAction.self,
		environment: { $0 })
)
