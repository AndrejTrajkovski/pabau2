import SwiftUI
import ComposableArchitecture

public let switchCellReducer = Reducer<Bool, ToggleAction, Any> { state, action, _ in
	switch action {
	case .setTo(let value):
		state = value
	}
	return .none
}

public enum ToggleAction: Equatable {
	case setTo(Bool)
}

public struct SwitchCell: View {

	public init (text: String, store: Store<Bool, ToggleAction>) {
		self.text = text
		self.store = store
	}

	let text: String
	let store: Store<Bool, ToggleAction>

	public var body: some View {
		WithViewStore(store) { viewStore in
			SwitchCellRaw(text: text, value: viewStore.binding(get: { $0 },
															   send: { .setTo($0)})
			)
		}
	}
}

public struct SwitchCellRaw: View {
	
	public init (text: String, value: Binding<Bool>) {
		self.text = text
		self._value = value
	}
	
	let text: String
	@Binding var value: Bool
	public var body: some View {
		VStack {
			HStack {
				Text(text).font(.regular17)
				Spacer()
				Toggle.init(isOn: $value, label: { EmptyView() })
				Spacer()
			}
			Divider()
		}
	}
}
