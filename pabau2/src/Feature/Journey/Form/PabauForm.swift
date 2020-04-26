import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

let fieldsReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> =
	indexed(reducer: fieldReducer,
					\CheckInContainerState.currentFields,
					/CheckInMainAction.form, { $0 })

let fieldReducer: Reducer<CSSField, CheckInFormAction, JourneyEnvironemnt> =
(
	cssClassReducer.pullback(
					 value: \CSSField.cssClass,
					 action: /CheckInFormAction.self,
					 environment: { $0 })
)

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
		print("pabau form body")
		return List {
			ForEachWithIndex(viewStore.value, id: \.self) { index, cssValue in
				FormSectionField(store:
					self.store.scope(
						value: { _ in cssValue },
						action: { .form(Indexed(index: index, value: $0)) }
				))
				.equatable()
			}
		}
	}
}
