import SwiftUI

struct DropdownTitle: View {
	let title: String
	let expanded: Bool
	let action: () -> Void
	var body: some View {
		Button(action: action) {
			HStack {
				DropdownRow(title: title)
					.foregroundColor(.black)
				Image(systemName: expanded ? "chevron.down" : "chevron.up")
					.foregroundColor(.blue)
			}
		}
	}
}
