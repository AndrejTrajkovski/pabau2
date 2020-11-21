import SwiftUI
import Model
import ComposableArchitecture
import Util
import Form
import ListPicker

public typealias AddAppointmentEnv = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

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
	static let clientState: PickerContainerState<Client> =
		PickerContainerState.init(
			dataSource: [
				Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
				Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
			],
			chosenItemId: 1,
			isActive: false)

	static let serviceState: PickerContainerState<Service> =
		PickerContainerState.init(
			dataSource: [
				Service.init(id: 1, name: "Botox", color: "", categoryId: 1, categoryName: "Injectables"),
				Service.init(id: 2, name: "Fillers", color: "", categoryId: 2, categoryName: "Urethra"),
				Service.init(id: 3, name: "Facial", color: "", categoryId: 3, categoryName: "Mosaic")
			],
			chosenItemId: 1,
			isActive: false)

	static let durationState: PickerContainerState<Duration> =
		PickerContainerState.init(
			dataSource: [
				Duration.init(name: "00:30", id: 1, duration: 30),
				Duration.init(name: "01:00", id: 2, duration: 60),
				Duration.init(name: "01:30", id: 3, duration: 90)
			],
			chosenItemId: 1,
			isActive: false)

	static let withState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 123, name: "Andrej Trajkovski", locationId: Location.randomId()),
				Employee.init(id: 456, name: "Mark Ronson", locationId: Location.randomId())
			],
			chosenItemId: 456,
			isActive: false)

	static let participantsState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Participant 1", locationId: Location.randomId()),
				Employee.init(id: 2, name: "Participant 2", locationId: Location.randomId())
			],
			chosenItemId: 1,
			isActive: false)
}
