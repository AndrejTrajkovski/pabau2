import Model
import SwiftUI
import ComposableArchitecture
import CasePaths

public enum CheckInFormAction {
	case multipleChoice(MultipleChoiceAction)
	case radio(RadioAction)
}

struct PabauForm: View {
	let store: Store<[CSSField], CheckInMainAction>
//	var viewStore: ViewStore<[CSSField], CheckInFormAction>
	public var body: some View {
		ForEach(store.view.value.indices) { (index: Int) in
			FormBuilder.makeSection(store:
				self.store.scope(
					value: { $0[index] },
					action: { .form(Indexed(index: index, value: $0)) }
			),
			cssClass: self.store.view.value[index].cssClass,
			index: index)
		}
	}
}

extension CSSField {
//	var multipleChoice: MultipleChoiceState {
//		get {
//			MultipleChoiceState(field: self,
//													checkBox:
//				extract(case: CSSClass.checkbox, from: self.cssClass)!)
//		}
//		set {
//			self.cssClass = CheckBox(newValue., <#T##choices: [CheckBoxChoice]##[CheckBoxChoice]#>)
//		}
//	}
}

enum FormBuilder {

	static func makeSection(store: Store<CSSField, CheckInFormAction>,
													cssClass: CSSClass,
													index: Int) -> some View {
		switch cssClass {
		case .checkboxes(let checkBoxes):
			return AnyView(
				MultipleChoiceField(
					store: store.scope(
						value: { _ in checkBoxes },
						action: { .multipleChoice($0) }))
			)
		case .staticText(let text):
			return AnyView(
				Text(text.text)
			)
		case .radio(let radio):
			return AnyView(
				RadioView(
					store: store.scope(
					value: { _ in radio },
					action: { .radio($0) }))
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
