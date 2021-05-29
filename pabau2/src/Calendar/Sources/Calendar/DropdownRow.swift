import SwiftUI

struct DropdownRow: View {
	let title: String
	
	var body: some View {
		Text(title)
			.bold()
			.padding()
			.frame(height: 48)
	}
}
