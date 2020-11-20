import SwiftUI
import Model
import ComposableArchitecture
import Util
import Form
import ListPicker

public struct Duration: ListPickerElement {
	public var name: String
	public var id: Int
	public var duration: TimeInterval
}

public struct AddAppointmentState: Equatable {
	var reminder: Bool
	var email: Bool
	var sms: Bool
	var feedback: Bool
	var isAllDay: Bool
	var clients: PickerContainerState<Client>
	var startDate: Date
	var services: ChooseServiceState
	var durations: PickerContainerState<Duration>
	var with: PickerContainerState<Employee>
	var participants: PickerContainerState<Employee>
}

public enum AddAppointmentAction: Equatable {
	case saveAppointmentTap
	case addAppointmentDismissed
	case chooseStartDate
	case clients(PickerContainerAction<Client>)
	case services(ChooseServiceAction)
	case durations(PickerContainerAction<Duration>)
	case with(PickerContainerAction<Employee>)
	case participants(PickerContainerAction<Employee>)
	case closeBtnTap
	case didTapServices
	case sms(ToggleAction)
	case reminder(ToggleAction)
	case email(ToggleAction)
	case feedback(ToggleAction)
}

extension Employee: ListPickerElement { }
extension Service: ListPickerElement { }

let addAppTapBtnReducer = Reducer<AddAppointmentState?,
	AddAppointmentAction, JourneyEnvironment> { state, action, _ in
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
	AddAppointmentAction, JourneyEnvironment> = .combine(
		PickerReducer<Client>().reducer.pullback(
			state: \AddAppointmentState.clients,
			action: /AddAppointmentAction.clients,
			environment: { $0 }),
		chooseServiceReducer.pullback(
			 state: \AddAppointmentState.services,
			 action: /AddAppointmentAction.services,
			 environment: { $0 }),
		PickerReducer<Duration>().reducer.pullback(
			state: \AddAppointmentState.durations,
			action: /AddAppointmentAction.durations,
			environment: { $0 }),
		PickerReducer<Employee>().reducer.pullback(
			state: \AddAppointmentState.with,
			action: /AddAppointmentAction.with,
			environment: { $0 }),
		PickerReducer<Employee>().reducer.pullback(
			state: \AddAppointmentState.participants,
			action: /AddAppointmentAction.participants,
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
			environment: { $0 })
	)

public let addAppointmentReducer: Reducer<AddAppointmentState?,
	AddAppointmentAction, JourneyEnvironment> = .combine(
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
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	public init(store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	public var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 32) {
					AddAppSections(store: self.store)
						.environmentObject(KeyboardFollower())
					PrimaryButton(Texts.saveAppointment) {
						self.viewStore.send(.saveAppointmentTap)
					}
					.frame(width: 315, height: 52)
					Spacer()
				}
			}
			.padding(24)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct Section1: View {
	@State var isAllDay: Bool = true
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack (spacing: 24.0) {
			SwitchCell(text: "All Day", value: $isAllDay)
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelAndTextField.init("CLIENT", self.viewStore.state.clients.chosenItemName ?? "")
				}, store: self.store.scope(state: { $0.clients },
										   action: { .clients($0) })
				)
				LabelAndTextField.init("DAY", self.viewStore.state.startDate.toString())
			}
		}
	}
}

struct Section2: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Services").font(.semibold24)
			HStack(spacing: 24.0) {
				LabelAndTextField.init("SERVICE", self.viewStore.state.services.chosenServiceName).onTapGesture {
					self.viewStore.send(.didTapServices)
				}
				NavigationLink.emptyHidden(self.viewStore.state.services.isChooseServiceActive,
																	 ChooseService(store: self.store.scope(state: { $0.services }, action: {
																		.services($0)
																		}))
				)
				PickerContainerStore.init(content: {
					LabelAndTextField.init("DURATION", self.viewStore.state.durations.chosenItemName ?? "")
				}, store: self.store.scope(state: { $0.durations },
																	action: { .durations($0) })
				)
			}
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelHeartAndTextField.init("WITH", self.viewStore.state.with.chosenItemName ?? "",
																			true)
				}, store: self.store.scope(state: { $0.with },
																	action: { .with($0) })
				)
				PickerContainerStore.init(content: {
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
																	action: { .participants($0) })
				)
			}
		}
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
		VStack(alignment: .leading, spacing: 32) {
			Section1(store: self.store)
			Section2(store: self.store)
			NotesSection()
			FourSwitchesSection(
				swithc1: viewStore.binding(
					get: { $0.reminder },
					send: { .reminder(.setTo($0)) }),
				switch2: viewStore.binding(
					get: { $0.email },
					send: { .email(.setTo($0)) }),
				switch3: viewStore.binding(
					get: { $0.sms },
					send: { .sms(.setTo($0)) }),
				switch4: viewStore.binding(
					get: { $0.feedback },
					send: { .feedback(.setTo($0)) }),
				switchNames: [
					Texts.sendReminder,
					Texts.sendConfirmationEmail,
					Texts.sendConfirmationSMS,
					Texts.sendFeedbackSurvey
				],
				title: Texts.communications
			)
		}.padding(.bottom, keyboardHandler.keyboardHeight)
			.navigationBarTitle(Text("New Appointment"), displayMode: .large)
			.navigationBarItems(leading:
									XButton(onTouch: { self.viewStore.send(.closeBtnTap) })
		)
	}
}

extension Client: ListPickerElement {
	public var name: String {
		return firstName + " " + lastName
	}
}

struct LabelHeartAndTextField: View {
	let labelTxt: String
	let valueText: String
	@State var isHearted: Bool
	init(_ labelTxt: String,
			 _ valueText: String,
			 _ isHearted: Bool) {
		self.labelTxt = labelTxt
		self.valueText = valueText
		self._isHearted = State.init(initialValue: isHearted)
	}
	var body: some View {
		LabelAndLowerContent(labelTxt) {
			HStack {
				Image(systemName: self.isHearted ? "heart.fill" : "heart")
					.foregroundColor(.heartRed)
					.onTapGesture {
						self.isHearted.toggle()
				}
				Text(self.valueText)
					.foregroundColor(Color.textFieldAndTextLabel)
					.font(.semibold15)
			}
		}
	}
}

struct LabelAndTextField: View {
	let labelTxt: String
	let valueText: String
	init(_ labelTxt: String,
			 _ valueText: String) {
		self.labelTxt = labelTxt
		self.valueText = valueText
	}
	var body: some View {
		LabelAndLowerContent(labelTxt) {
			Text(self.valueText)
				.foregroundColor(Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

struct LabelAndLowerContent<Content: View>: View {
	init(_ labelTxt: String,
			 @ViewBuilder _ lowerContent: @escaping () -> Content) {
		self.labelTxt = labelTxt
		self.lowerContent = lowerContent
	}
	let labelTxt: String
	let lowerContent: () -> Content
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.bold12)
			lowerContent()
			Divider().foregroundColor(.textFieldBottomLine)
		}
	}
}

struct NotesSection: View {
	@State var note: String = ""
	public var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Notes").font(.semibold24)
			LabelAndLowerContent.init("BOOKING NOTE") {
				TextField.init("Add a booking note", text: self.$note)
					.foregroundColor(Color.textFieldAndTextLabel)
					.font(.semibold15)
			}
		}
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
			clients: JourneyMocks.clientState,
			startDate: startDate,
			services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
			durations: JourneyMocks.durationState,
			with: JourneyMocks.withState,
			participants: JourneyMocks.participantsState
		)
	}
	
	public init(startDate: Date,
				endDate: Date,
				employee: Employee) {
		var employees = JourneyMocks.withState
		employees.dataSource.append(employee)
		employees.chosenItemId = employee.id
		self.init(
			reminder: false,
			email: false,
			sms: false,
			feedback: false,
			isAllDay: false,
			clients: JourneyMocks.clientState,
			startDate: startDate,
			services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
			durations: JourneyMocks.durationState,
			with: employees,
			participants: JourneyMocks.participantsState
		)
	}

	public static let dummy = AddAppointmentState.init(
		reminder: false,
		email: false,
		sms: false,
		feedback: false,
		isAllDay: false,
		clients: JourneyMocks.clientState,
		startDate: Date(),
		services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
		durations: JourneyMocks.durationState,
		with: JourneyMocks.withState,
		participants: JourneyMocks.participantsState
	)
}
