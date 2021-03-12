import SwiftUI

public struct EmptyDataView: View {
    let imageName: String
    let title: String
    let description: String

    public init(
        imageName: String,
        title: String,
        description: String
    ) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: 360.0,
                    height: 297.0,
                    alignment: Alignment(
                        horizontal: .center,
                        vertical: .center
                    )
                )
            Text(title)
                .font(.medium18)
                .foregroundColor(Color.init(hex: "#313131"))
            Text(description)
                .multilineTextAlignment(.center)
                .font(.medium16)
                .foregroundColor(Color.init(hex: "#9B9B9B"))
                .frame(width: 282, height: 48)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
    }
}
