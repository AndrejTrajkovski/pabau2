import SwiftUI

struct ExpandableButton: View {
	@Binding var expanded: Bool
	var body: some View {
		Button(action: { self.expanded = !expanded },
			   label: {
				Image(systemName: expanded ? "chevron.down" : "chevron.up")
					.font(.regular20)
					.foregroundColor(.blue)
			   })
	}
}
