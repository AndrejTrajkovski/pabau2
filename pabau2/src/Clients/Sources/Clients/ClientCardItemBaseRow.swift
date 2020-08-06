import SwiftUI

struct ClientCardItemBaseRow: View {
	let title: String
	let date: Date
	let image: Image
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				image
					.frame(width: 36, height: 44)
					.padding()
				VStack(alignment: .leading, spacing: 4) {
					Text(title).font(.semibold17)
					DateLabel(date: date).font(.regular15)
				}
			}
			Divider()
		}
			.frame(height: 80)
	}
}
