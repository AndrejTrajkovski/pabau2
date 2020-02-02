import SwiftUI

struct TextFieldWithBottomLine: View {
    @Binding var text: String
    private var placeholder = ""
    private let lineThickness = CGFloat(1.0)

		init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
				self._text = text
    }

    var body: some View {
        VStack {
					TextField(placeholder, text: $text)
            HorizontalLine(color: .black)
        }.padding(.bottom, lineThickness)
    }
}

struct HorizontalLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let fill = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        var path = Path()
        path.addRoundedRect(in: fill, cornerSize: CGSize(width: 1, height: 2))
        return path
    }
}

struct HorizontalLine: View {
		private var color: Color = .textFieldBottomLine
    private var height: CGFloat = 1.0

    init(color: Color, height: CGFloat = 1.0) {
        self.color = color
        self.height = height
    }

    var body: some View {
			HorizontalLineShape().fill(self.color).frame(minWidth: 0, maxWidth: .infinity, minHeight: height, maxHeight: height).opacity(0.1)
    }
}
