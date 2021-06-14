import SwiftUI
import ComposableArchitecture
import Model
import Util

public enum EventType: Equatable, CaseIterable {
	case appointment
	case bookout
	case shift
	
	func title() -> String {
		switch self {
		case .appointment:
			return Texts.addAppointment
		case .bookout:
			return Texts.addBookout
		case .shift:
			return Texts.addShift
		}
	}
}

struct AddEventDropdown: View {
	let store: Store<Void, CalendarAction>

	var body: some View {
        ForEach(EventType.allCases, id: \.self) { eventType in
            AddEventRow(
                eventType: eventType,
                store: store
            )
        }.background(Color(hex: "F9F9F9"))
	}
}

struct AddEventRow: View {

	let eventType: EventType
	let store: Store<Void, CalendarAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(alignment: .leading) {
				Text(eventType.title())
					.foregroundColor(.blue)
					.padding()
			}
			.frame(height: 48)
			.onTapGesture {
				viewStore.send(.addEventDelay(eventType))
			}
		}
	}
}
