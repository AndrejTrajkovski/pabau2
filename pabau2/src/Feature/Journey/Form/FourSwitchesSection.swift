import SwiftUI

struct FourSwitchesSection: View {
	@Binding var swithc1: Bool
	@Binding var switch2: Bool
	@Binding var switch3: Bool
	@Binding var switch4: Bool
	let switchNames: [String]
	let title: String
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
