import SwiftUI
import Util

struct ChoosePathwayButton: View {
	let btnTxt: String
	let style: PathwayCellStyle
	let action: () -> Void
	var body: some View {
		Group {
			if self.style == .blue {
				BigButton.init(text: btnTxt,
											 btnTapAction: action)
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			} else {
				Button.init(action: action, label: {
					Text(btnTxt)
						.font(Font.system(size: 16.0, weight: .bold))
						.frame(minWidth: 0, maxWidth: .infinity)
				}).buttonStyle(PathwayWhiteButtonStyle())
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			}
		}
	}
}

//Font.system(size: 16.0, weight: .bold)
//struct SecondaryButton: View {
//
//	let action: () -> Void
//	let font: Font
//	let bntText
//	let blurRadius: CGFloat
//
//	var body: some View {
//		Button.init(action: action, label: {
//			Text(btnTxt)
//				.font(font)
//				.frame(minWidth: 0, maxWidth: .infinity)
//		}).buttonStyle(PathwayWhiteButtonStyle())
//			.shadow(color: Colors.btnShadowColor,
//							radius: blurRadius,
//							y: 2)
//			.background(style.btnColor)
//	}
//}
