import SwiftUI
import Model

private func asset(_ format: DocumentExtension) -> String {
	return "ico-clients-documents-" + format.rawValue
}

struct DocumentsList: ClientCardChild {
	var state: [Document]
	var body: some View {
		List {
			ForEach(state.indices, id: \.self) { idx in
				DocumentRow(doc: self.state[idx])
			}
		}
	}
}

struct DocumentRow: View {
	let doc: Document
	var body: some View {
		ClientCardItemBaseRow(title: doc.title,
													date: doc.date,
													image: Image(asset(doc.format)))
	}
}
