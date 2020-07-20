import SwiftUI

struct RibbonView: View {

	let currentStepIdx: Int
	let totalNumberOfSteps: Int

	private let lineWidth: CGFloat = 1
	var body: some View {
		ZStack(alignment: .bottom) {
			RoundedRectangle(cornerRadius: 36.5)
				.stroke(Color(hex: "979797"), lineWidth: lineWidth)
				.overlay(
					RoundedRectangle(cornerRadius: 36.5)
						.fill(Color.deepSkyBlue)
						.shadow(color: Color(hex: "007AFF"), radius: 1, x: 0, y: 5)
			)
				.padding(lineWidth)
			Text("\(currentStepIdx)/\(totalNumberOfSteps)")
				.foregroundColor(.white)
				.font(.bold18)
				.alignmentGuide(.bottom, computeValue: { dim in dim[.bottom] + 24 })
		}
		.frame(width: 73, height: 168)
	}
}
