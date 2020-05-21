import SwiftUI
import Model

struct SelectField: View {

	@Binding var select: Select

	var body: some View {
		ForEach(select.choices, id: \.self) { (choice: SelectChoice) in
			SelectRow(choice: choice, isSelected: self.select.selectedChoiceId == choice.id)
				.padding(4)
				.onTapGesture {
					let idx = self.select.choices.firstIndex(where: { $0.id == choice.id })
					self.select.selectedChoiceId = self.select.choices[idx!].id
			}
		}
	}
}

struct SelectRow: View {
	let choice: SelectChoice
	let isSelected: Bool
	
	var body: some View {
		HStack (alignment: .center, spacing: 16) {
			SelectImage(isSelected: isSelected)
			Text(choice.title)
				.foregroundColor(.black).opacity(0.9)
				.font(.regular16)
				.alignmentGuide(VerticalAlignment.center, computeValue: { return $0[VerticalAlignment.firstTextBaseline] - 4.5 })
		}
		.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

struct SelectImage: View {
	let isSelected: Bool
	var body: some View {
		Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
			.resizable()
			.foregroundColor( isSelected ? .accentColor : .checkBoxGray)
			.frame(width: 24, height: 24)
	}
}
