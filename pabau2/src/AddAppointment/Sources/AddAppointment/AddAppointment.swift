import SwiftUI
import Model
import ComposableArchitecture
import Util
import Form
import SharedComponents
import CoreDataModel

public struct AddAppointment: View {
	
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
        .toast(store: store.scope(state: \.toast))
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
