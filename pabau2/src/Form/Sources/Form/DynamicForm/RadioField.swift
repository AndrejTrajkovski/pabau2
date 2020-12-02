import SwiftUI
import ComposableArchitecture
import Model

public enum RadioFieldAction {
	case select(id: Int)
}

let radioFieldReducer = Reducer<RadioState, RadioFieldAction, FormEnvironment> { state, action, _ in
	switch action {
	case .select(let id):
		state.selectedChoiceId = id
	}
	return .none
}

struct RadioField: View {

	let store: Store<RadioState, RadioFieldAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				Picker(selection:
						viewStore.binding(get: { $0.selectedChoiceId },
										  send: { .select(id: $0) }
				),
					   label: EmptyView()) {
					ForEach(viewStore.choices, id: \.id) { (choice: RadioChoice) in
						Text(String(choice.title)).tag(choice.id)
					}
				}.pickerStyle(SegmentedPickerStyle())
			}
		}
	}
}

//struct RadioField: View {
//
//	init(radio: Binding<Radio>) {
//		self._radio = radio
//		self._selectedId = State.init(initialValue: radio.wrappedValue.selectedChoiceId)
//	}
//
//	@State var selectedId: Int
//	@Binding var radio: Radio
//
//	var body: some View {
//		VStack {
//			Picker(selection:
//				Binding.init(
//					get: {
//						self.selectedId
//				},
//					set: { (id: Int) in
//						self.selectedId = id
//						self.radio.selectedChoiceId = id
//				}),
//						 label: EmptyView()) {
//				ForEach(radio.choices, id: \.id) { (choice: RadioChoice) in
//					Text(String(choice.title)).tag(choice.id)
//				}
//			}.pickerStyle(SegmentedPickerStyle())
//		}
//	}
//}
