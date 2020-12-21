import SwiftUI
import Util

struct JourneyListContextMenu: View {
		let dataSource = Array(zip(systemImages, titles))
    var body: some View {
			VStack {
				ForEach(dataSource.indices) { idx in
					ContextMenuItem(imageName: self.dataSource[idx].0,
													title: self.dataSource[idx].1,
													action: {

					})
				}
			}
    }
}

struct JourneyListContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        JourneyListContextMenu()
    }
}

struct ContextMenuItem: View {
	let imageName: String
	let title: String
	let action: () -> Void
	var body: some View {
		Button.init(action: action,
								label: {
									Text(title)
									Image(systemName: imageName)
		})
	}
}

private let titles =
	[
		Texts.sales,
		Texts.delete,
		Texts.status,
		Texts.`repeat`,
		Texts.documents,
		Texts.reschedule
]

private let systemImages =
[
	"briefcase",
	"minus.circle",
	"arrowshape.turn.up.right",
	"repeat",
	"doc.text",
	"arrowshape.turn.up.right"
]
