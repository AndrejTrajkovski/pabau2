import SwiftUI

struct AftercareCell: View {
	let channel: AftercareChannel
	let title: String
	@Binding var value: Bool

	var body: some View {
		VStack {
			HStack {
				Image(systemName: channel == .sms ? "message.circle" : "envelope.circle")
				Text(title).font(.body)
				Toggle(isOn: $value, label: { EmptyView() })
			}.padding([.leading, .trailing])
			Divider()
		}
	}
}
