import SwiftUI

struct AftercareCell: View {
	let type: AftercareCellType
	let title: String
	@Binding var value: Bool

	var body: some View {
		HStack {
			Image(systemName: type == .sms ? "message.circle" : "envelope.circle")
			Text(title).font(.body)
			Toggle(isOn: $value, label: { EmptyView() })
		}
	}
}

enum AftercareCellType {
	case sms
	case email

	init(channel: AftercareChannel) {
		switch channel {
		case .email:
			self = .email
		case .sms:
			self = .sms
		}
	}
}
