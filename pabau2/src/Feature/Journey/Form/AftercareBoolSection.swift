import ComposableArchitecture
import SwiftUI
import ASCollectionView

public enum AftercareBoolAction {
	case indexedToggle(Indexed<ToggleAction>)
}

struct AftercareBoolSection {
	let id: Int
	let title: String
	let desc: String
	let store: Store<[AftercareOption], AftercareBoolAction>
	@ObservedObject var viewStore: ViewStore<[AftercareOption], AftercareBoolAction>

	init(id: Int,
			 title: String,
			 desc: String,
			 store: Store<[AftercareOption], AftercareBoolAction>) {
		self.id = id
		self.title = title
		self.desc = desc
		self.store = store
		self.viewStore = ViewStore(store)
	}

	func makeSection() -> ASCollectionViewSection<Int> {
		ASCollectionViewSection(
			id: id,
			data: self.viewStore.state,
			dataID: \.self) { aftercare, context in
				AftercareCell(channel: aftercare.channel,
											title: aftercare.title,
											value: Binding.init(
												get: { aftercare.isSelected },
												set: { self.viewStore
													.send(.indexedToggle(Indexed(context.index, ToggleAction.setTo($0)))) })
				)
		}
		.sectionHeader { AftercareBoolHeader(title: title, desc: desc) }
	}
}

private struct AftercareBoolHeader: View {
	
	let title: String
	let desc: String
	var body: some View {
		VStack(alignment: .leading, spacing: 24) {
			Text(title)
				.font(.bold24)
			Text(desc).font(.regular18)
				.multilineTextAlignment(.leading)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
	}
}
