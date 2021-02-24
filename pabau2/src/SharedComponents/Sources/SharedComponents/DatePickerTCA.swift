import ComposableArchitecture
import SwiftUI

public let datePickerReducer: Reducer<Date?, DatePickerTCAAction, Any> =
	.init { state, action, _ in
		switch action {
		case .onChange(let date):
			state = date
		}
		return .none
	}

public enum DatePickerTCAAction: Equatable {
	case onChange(Date?)
}

public struct DatePickerTCA: View {

	public init(mode: UIDatePicker.Mode, store: Store<Date?, DatePickerTCAAction>) {
		self.store = store
		self.mode = mode
	}

	let store: Store<Date?, DatePickerTCAAction>
	let mode: UIDatePicker.Mode

	public var body: some View {
		WithViewStore(store) {
			DatePickerTextField(date: $0.binding(get: { $0 },
												 send: { .onChange($0)}),
								mode: mode,
								borderStyle: .roundedRect)
		}.debug("DatePickerTCA")
	}
}
