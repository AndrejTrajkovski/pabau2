import SwiftUI
import ComposableArchitecture
import Model
import Util

struct CalTopBar: View {
	let store: Store<CalendarState, CalendarAction>
	@ObservedObject var viewStore: ViewStore<CalendarState, CalendarAction>
	
	init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				addButtons
					.padding(.leading, 20)
					.exploding(.leading)
				CalendarTypePicker(
					store:
						self.store.scope(
							state: { $0.calTypePicker },
							action: { .calTypePicker($0) }
						)
				)
				.padding()
				.exploding(.center)
				HStack {
					Button {
						viewStore.send(.changeCalScope)
					} label: {
						Image("calendar_icon")
							.renderingMode(.template)
							.accentColor(.blue)
					}
					Button(Texts.filters, action: {
						viewStore.send(.toggleFilters)
					})
				}
				.padding()
				.padding(.trailing, 20)
				.exploding(.trailing)
			}
			.frame(height: 50)
			.background(Color(hex: "F9F9F9"))
			Divider()
		}
	}
	
	var addButtons: some View {
		HStack {
			PlusButton {
				withAnimation(Animation.easeIn(duration: 0.5)) {
					self.viewStore.send(.addAppointmentTap)
				}
			}
			PlusButton {
				self.viewStore.send(.onAddShift)
			}
		}
	}
}
