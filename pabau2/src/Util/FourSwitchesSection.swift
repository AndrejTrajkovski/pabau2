import SwiftUI

public struct FourSwitchesSection: View {
	@Binding var swithc1: Bool
	@Binding var switch2: Bool
	@Binding var switch3: Bool
	@Binding var switch4: Bool
	let switchNames: [String]
	let title: String
	
	public init (
		swithc1: Binding<Bool>,
		switch2: Binding<Bool>,
		switch3: Binding<Bool>,
		switch4: Binding<Bool>,
		switchNames: [String],
		title: String
		) {
		self._swithc1 = swithc1
		self._switch2 = switch2
		self._switch3 = switch3
		self._switch4 = switch4
		self.switchNames = switchNames
		self.title = title
	}
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 8.0) {
			Text(title).font(.semibold24)
				.padding([.top, .bottom])
			SwitchCell.init(text: switchNames[0], value: $swithc1)
			SwitchCell.init(text: switchNames[1], value: $switch2)
			SwitchCell.init(text: switchNames[2], value: $switch3)
			SwitchCell.init(text: switchNames[3], value: $switch4)
		}
	}
}

public struct SwitchCell: View {
	
	public init (text: String, value: Binding<Bool>) {
		self.text = text
		self._value = value
	}
	
	let text: String
	@Binding var value: Bool
	public var body: some View {
		VStack {
			HStack {
				Text(text).font(.regular17)
				Spacer()
				Toggle.init(isOn: $value, label: { EmptyView() })
				Spacer()
			}
			Divider()
		}
	}
}
