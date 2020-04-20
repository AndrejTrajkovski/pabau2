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
	@ObservedObject var viewStore: ViewStore<[CSSField], CheckInMainAction>

	init(store: Store<[CSSField], CheckInMainAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	public var body: some View {
		ForEachWithIndex(viewStore.value, id: \.self) { index, item in
			FormBuilder.makeSection(store:
				self.store.scope(
					value: { $0[index] },
					action: { .form(Indexed(index: index, value: $0)) }
			),
			cssClass: self.viewStore.value[index].cssClass,
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



public struct ForEachWithIndex<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (_ index: Data.Index, _ element: Data.Element) -> Content

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        ForEach(
            zip(self.data.indices, self.data).map { index, element in
                IndexInfo(
                    index: index,
                    id: self.id,
                    element: element
                )
            },
            id: \.elementID
        ) { indexInfo in
            self.content(indexInfo.index, indexInfo.element)
        }
    }
}

extension ForEachWithIndex where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
    public init(_ data: Data, @ViewBuilder content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

private struct IndexInfo<Index, Element, ID: Hashable>: Hashable {
    let index: Index
    let id: KeyPath<Element, ID>
    let element: Element

    var elementID: ID {
        self.element[keyPath: self.id]
    }

    static func == (_ lhs: IndexInfo, _ rhs: IndexInfo) -> Bool {
        lhs.elementID == rhs.elementID
    }

    func hash(into hasher: inout Hasher) {
        self.elementID.hash(into: &hasher)
    }
}
