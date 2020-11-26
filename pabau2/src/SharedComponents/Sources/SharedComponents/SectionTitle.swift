import SwiftUI

struct SectionTitle: View {
	let title: String
	var body: some View {
		Text(title).font(.semibold24)
			.frame(maxWidth: .infinity, alignment: .leading)
	}
}
