import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents
import CoreDataModel
import ChooseLocationAndEmployee

struct FirstSection: View {
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 16) {
				Buttons().isHidden(true, remove: true)
				SwitchCell(
					text: Texts.allDay,
					store: store.scope(
						state: { $0.isAllDay },
						action: { .isAllDay($0)}
					)
				)
				ChooseLocationAndEmployee(store:
											store.scope(state: { $0.chooseLocAndEmp },
														action: { .chooseLocAndEmp($0) }
											)
				)
			}.wrapAsSection(title: "Add Bookout")
		}
	}
}
