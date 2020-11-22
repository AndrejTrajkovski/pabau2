import ComposableArchitecture
import SwiftUI
import Util

public enum TextChangeAction: Equatable {
	case textChange(String)
}

public let textFieldReducer: Reducer<String, TextChangeAction, Any> = .init {
	state, action, env in
	switch action {
	case .textChange(let text):
		state = text
	}
	return .none
}

public struct TitleAndTextField: View {
	public init(title: String, tfLabel: String, store: Store<String, TextChangeAction>) {
		self.title = title
		self.tfLabel = tfLabel
		self.store = store
	}
	
	let title: String
	let tfLabel: String
	let store: Store<String, TextChangeAction>
	public var body: some View {
		TitleAndLowerContent(title) {
			TextFieldStore(tfLabel: tfLabel, store: store)
				.foregroundColor(Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

public struct TextFieldStore: View {
	
	public init(tfLabel: String? = nil, store: Store<String, TextChangeAction>) {
		self.tfLabel = tfLabel
		self.store = store
	}
	
	let tfLabel: String?
	let store: Store<String, TextChangeAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			TextField(tfLabel ?? "", text: viewStore.binding(get: { $0 },
															 send: TextChangeAction.textChange))
		}
	}
}
