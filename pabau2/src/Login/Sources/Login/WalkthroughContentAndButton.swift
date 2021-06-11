import SwiftUI
import Util

public struct WalkthroughContentAndButton: View {
	let content: WalkthroughContentContent
	let btnTitle: String
	let btnAction: () -> Void
    
	public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 50) {
                WalkthroughContentView.init(state: content)
                PrimaryButton(btnTitle, btnAction)
            }.frame(width: min(geometry.size.width * 0.8, 495))
            .position(
                x: geometry.size.width * 0.5,
                y: geometry.size.height * 0.3
            )
        }
	}
}
