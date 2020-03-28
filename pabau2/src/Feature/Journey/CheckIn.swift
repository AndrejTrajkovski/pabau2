import SwiftUI
import Util

struct CheckIn: View {
	var body: some View {
		ZStack {
		Rectangle().fill(
			LinearGradient(gradient: .init(colors: [.checkInGradient1, .deepSkyBlue]), startPoint: .top, endPoint: .bottom)
			)
		Circle()
		.overlay(
			ZStack {
				Text("SC").foregroundColor(.white).font(.regular90)
				Circle()
					.stroke(Color.white, lineWidth: 3.0)
			}
			).foregroundColor(Color.clear)
			.frame(width: 240, height: 240)
		}
	}
}
