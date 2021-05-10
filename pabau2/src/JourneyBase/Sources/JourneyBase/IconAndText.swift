import SwiftUI

public struct IconAndText: View {
    let text: String
    let image: Image
    let textColor: Color
    public init(_ image: Image,
         _ text: String,
         _ textColor: Color = .black) {
        self.image = image
        self.text = text
        self.textColor = textColor
    }
    public var body: some View {
        HStack {
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue2)
                .frame(width: 20, height: 20)
            Text(text)
                .font(Font.semibold11)
                .foregroundColor(textColor)
        }
    }
}
