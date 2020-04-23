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
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		List {
			ForEachWithIndex(viewStore.value, id: \.self) { index, cssValue in
				FormSectionView(store:
					self.store.scope(
						value: { _ in cssValue },
						action: { .form(Indexed(index: index, value: $0)) }
				))
			}
		}
	}
}
