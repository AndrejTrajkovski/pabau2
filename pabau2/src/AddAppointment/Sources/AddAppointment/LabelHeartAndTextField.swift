import SwiftUI
import Util

struct LabelHeartAndTextField: View {
	let labelTxt: String
	let valueText: String
	@State var isHearted: Bool
	init(_ labelTxt: String,
			 _ valueText: String,
			 _ isHearted: Bool) {
		self.labelTxt = labelTxt
		self.valueText = valueText
		self._isHearted = State.init(initialValue: isHearted)
	}
	var body: some View {
		TitleAndLowerContent(labelTxt, .constant(nil)) {
			HStack {
				Image(systemName: self.isHearted ? "heart.fill" : "heart")
					.foregroundColor(.heartRed)
					.onTapGesture {
						self.isHearted.toggle()
				}
				Text(self.valueText)
					.foregroundColor(Color.textFieldAndTextLabel)
					.font(.semibold15)
			}
		}
	}
}
