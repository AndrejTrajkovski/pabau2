import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

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
		ForEachWithIndex(viewStore.value, id: \.self) { index, cssValue in
			FormSectionView(store:
				self.store.scope(
					value: { _ in cssValue },
					action: { .form(Indexed(index: index, value: $0)) }
			))
//			FormBuilder.makeSection(store:
//				self.store.scope(
//					value: { _ in cssValue },
//					action: { .form(Indexed(index: index, value: $0)) }
//			),
//			cssClass: cssValue.cssClass)
		}
	}
}

enum FormBuilder {

	static func makeSection(store: Store<CSSField, CheckInFormAction>,
													cssClass: CSSClass) -> some View {
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
}
