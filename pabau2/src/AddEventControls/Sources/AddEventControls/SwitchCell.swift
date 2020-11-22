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

//FIXME: Refactor with store object here
public struct SwitchCell: View {
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
