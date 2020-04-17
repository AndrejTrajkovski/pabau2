import Model
import SwiftUI
import ComposableArchitecture

struct PabauForm: View {
	let store: Store<[CSSField], CheckInMainAction>
	public var body: some View {
		FormBuilder.makeForm(store: self.store)
	}
}

enum FormBuilder {
	
	static func makeForm(store: Store<CheckInContainerState, CheckInMainAction>) -> some View {
		
	}
	
	
	
	static func makeForm(store: Store<[CSSField], CheckInMainAction>) -> some View {
		List {
			ForEach(store.value.cssFields, id: \.id, content: { (cssField: CSSField) in
				return makeSection(cssField: cssField)
			})
		}
	}

	static func makeSection(cssField: CSSField) -> some View {
		switch cssField.cssClass {
		case .checkbox(let checkBox):
			return AnyView(makeSection(checkBox, field: cssField))
		default:
			return AnyView(EmptyView())
		}
	}
	
	static func makeSection(_ checkBox: CheckBox, field: CSSField) -> some View {
		return Section(header: Text(field.title ?? ""),
									 content: {
			MultipleChoiceField(store: <#T##Store<MultipleChoiceState, MultipleChoiceAction>#>, viewStore: <#T##ViewStore<MultipleChoiceField.State, MultipleChoiceAction>#>)
		})
	}
}
