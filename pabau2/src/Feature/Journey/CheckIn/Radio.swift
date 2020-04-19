import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public struct RadioState: Codable, Equatable {
	public var id: Int
	public var choices: [RadioChoice]
	public var selectedChoiceId: Int
}

enum RadioAction {
	case didSelectChoice(Int)
}

func radioReducer(state: inout RadioState,
									action: RadioAction,
									environment: JourneyEnvironemnt) -> [Effect<RadioAction>] {
	switch action {
	case .didSelectChoice(let id):
		state.selectedChoiceId = id
	}
	return []
}

struct RadioView: View {
	let store: Store<Radio, RadioAction>
	@ObservedObject var viewStore: ViewStore<RadioState, RadioAction>
	var body: some View {
		VStack {
			Picker(selection: self.store.binding(
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
