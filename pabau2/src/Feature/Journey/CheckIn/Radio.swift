import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

//public struct RadioState: Codable, Equatable {
//	public var cssField: CSSField
//	public var id: Int
//	public var choices: [RadioChoice]
//	public var selectedChoiceId: Int
//	
//	init(cssField: CSSField, radio: Radio) {
//		self.cssField = cssField
//		self.id = radio.id
//		self.choices = radio.choices
//		self.selectedChoiceId = radio.selectedChoiceId
//	}
//}

public enum RadioAction {
	case didSelectChoice(Int)
}

let radioReducer = Reducer<Radio, RadioAction, JourneyEnvironemnt> {
	state, action, environment in
	switch action {
	case .didSelectChoice(let id):
		state.selectedChoiceId = id
	}
	return []
}

struct RadioView: View {
	let store: Store<Radio, RadioAction>
	@ObservedObject var viewStore: ViewStore<Radio, RadioAction>
	
	init(store: Store<Radio, RadioAction>) {
		self.store = store
		self.viewStore = self.store
//		.scope(
//			value: RadioState.init(radio:),
//			action: { $0 })
		.view
	}
	
	var body: some View {
		VStack {
			Picker(selection: self.viewStore.binding(
				value: \.selectedChoiceId,
				action: /RadioAction.didSelectChoice),
						 label: Text("Radio")
			) {
				ForEach(store.view.value.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}
