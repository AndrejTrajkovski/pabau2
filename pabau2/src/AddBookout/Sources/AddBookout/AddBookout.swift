import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents
import CoreDataModel
import ChooseLocationAndEmployee

public let addBookoutOptReducer: Reducer<
	AddBookoutState?,
	AddBookoutAction,
	AddBookoutEnvironment
> = .combine(
	addBookoutReducer.optional().pullback(
		state: \.self,
		action: /AddBookoutAction.self,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
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
	chooseLocationAndEmployeeReducer.pullback(
		state: \AddBookoutState.chooseLocAndEmp,
		action: /AddBookoutAction.chooseLocAndEmp,
		environment: makeChooseLocAndEmpEnv(_:)
	),
	chooseBookoutReasonReducer.pullback(
		state: \AddBookoutState.chooseBookoutReasonState,
		action: /AddBookoutAction.chooseBookoutReason,
		environment: { $0 }),
	switchCellReducer.pullback(
		state: \.isAllDay,
		action: /AddBookoutAction.isAllDay,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .saveBookout:

			let isValid = state.chooseLocAndEmp.validate()

			if !isValid { break }

			state.showsLoadingSpinner = true
			
			return env.repository.clientAPI.createAppointment(appointment: state.appointmentsBody)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map(AddBookoutAction.appointmentCreated)
				.eraseToEffect()
		case .chooseStartDate(let day):
			guard let day = day else {
				break
			}
			state.startDate = day
		case .chooseTime(let time):
			state.timeValidator = nil
			state.time = time
		case .onChooseBookoutReason:
			state.chooseBookoutReasonState.isChooseBookoutReasonActive = true
		default:
			break
		}
		return .none
	}
)

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
                .padding(.top, 30)
            AddEventPrimaryBtn(title: "Save Bookout") {
                viewStore.send(.saveBookout)
            }.padding([.top, .bottom], 30)
        }
		.addEventWrapper(onXBtnTap: { viewStore.send(.close) })
		.loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
	}
}
