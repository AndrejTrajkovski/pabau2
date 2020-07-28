import ModelPackage
import SwiftUI
import ComposableArchitecture
import CasePaths
import UtilPackage

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
		}
	}
}
