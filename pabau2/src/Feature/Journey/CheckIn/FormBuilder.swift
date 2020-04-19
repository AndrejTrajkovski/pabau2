import Model
import SwiftUI
import ComposableArchitecture
import CasePaths

public enum CheckInFormAction {
	case multipleChoice(Indexed<MultipleChoiceAction>)
}

struct PabauForm: View {
	let store: Store<[CSSField], CheckInFormAction>
//	var viewStore: ViewStore<[CSSField], CheckInFormAction>
	public var body: some View {
		ForEach(store.view.value.indices) { (index: Int) in
			FormBuilder.makeSection(store:
				self.store.scope(
					value: { $0[index] },
					action: { $0 }
			),
			cssClass: self.store.view.value[index].cssClass,
			index: index)
		}
	}
}

enum FormBuilder {

	static func makeSection(store: Store<CSSField, CheckInFormAction>,
													cssClass: CSSClass,
													index: Int) -> some View {
		switch cssClass {
		case .checkbox(let checkBox):
			return AnyView(
				MultipleChoiceField(
					store: store.scope(
						value: { MultipleChoiceState(field: $0, checkBox: checkBox) },
						action: { .multipleChoice(Indexed(index: index, value: $0)) })))
		case .staticText(let text):
			return AnyView(
				Text(text.text)
			)
		default:
			return AnyView(EmptyView())
		}
	}
	
//	static func makeSection(_ checkBox: CheckBox, field: CSSField) -> some View {
//		return Section(header: Text(field.title ?? ""),
//									 content: {
//			MultipleChoiceField(store: <#T##Store<MultipleChoiceState, MultipleChoiceAction>#>, viewStore: <#T##ViewStore<MultipleChoiceField.State, MultipleChoiceAction>#>)
//		})
//	}
}
