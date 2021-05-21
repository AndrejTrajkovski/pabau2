import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

struct DescriptionAndNotes: View {

	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	public init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack(spacing: 16) {
			TitleAndValueLabel(
				"DESCRIPTION",
				self.viewStore.state.chooseBookoutReasonState.chosenReasons?.name ?? "Add description",
				self.viewStore.state.chooseBookoutReasonState.chosenReasons?.name == nil ? Color.grayPlaceholder : nil
			).onTapGesture {
				self.viewStore.send(.onChooseBookoutReason)
			}
			NavigationLink.emptyHidden(
				self.viewStore.state.chooseBookoutReasonState.isChooseBookoutReasonActive,
				ChooseBookoutReasonView(
					store: self.store.scope(
						state: { $0.chooseBookoutReasonState },
						action: { .chooseBookoutReason($0) }
					)
				)
			)
			TitleAndTextField(
				title: "NOTE",
				tfLabel: "Add a note.",
				store: store.scope(
					state: { $0.note },
					action: { .note($0)}
				)
			)
			SwitchCell(
				text: "Private Bookout",
				store: store.scope(
					state: { $0.isPrivate },
					action: { .isPrivate($0) }
				)
			)
		}.wrapAsSection(title: "Description & Notes")
	}
}
