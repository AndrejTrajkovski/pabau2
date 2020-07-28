import SwiftUI
import UtilPackage
import ComposableArchitecture

struct FormsPages: View {
	
	let store: Store<CheckInViewState, CheckInBodyAction>
	var body: some View {
		print("FormsPages")
		return WithViewStore(self.store, removeDuplicates: { _, _ in return false }) { viewStore in
			PageView(
				viewStore.state.forms.indices.map { idx in
					FormWrapper(
						store: self.store.scope(
							state: { $0.forms[idx].form },
							action: { .updateForm(Indexed(idx, $0)) }
						)
					)
				},
				viewStore.binding(
					get: { $0.selectedIndex },
					send: { CheckInBodyAction.stepsView(.didSelectFormIndex($0))}
				)
			)
		}
	}
}
