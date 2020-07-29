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
	@Binding var options: [AftercareOption]

	init(id: Int,
			 title: String,
			 desc: String,
			 options: Binding<[AftercareOption]>) {
		self.id = id
		self.title = title
		self.desc = desc
		self._options = options
	}

	var section: ASCollectionViewSection<Int> {
		ASCollectionViewSection(
			id: id,
			data: self.options,
			dataID: \.self) { aftercare, context in
				AftercareCell(channel: aftercare.channel,
											title: aftercare.title,
											value: self.$options[context.index].isSelected
				)
		}
		.sectionHeader { AftercareBoolHeader(title: title, desc: desc) }
	}
}

struct AftercareBoolHeader: View {

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
