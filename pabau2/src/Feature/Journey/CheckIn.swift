import SwiftUI
import Util

public struct CheckIn: View {
	@State private var animationFlag = false
	var player = Player()
	public init () {}
	public var body: some View {
		ZStack {
			Rectangle().fill(
				LinearGradient(gradient: .init(colors: [.checkInGradient1, .deepSkyBlue]), startPoint: .top, endPoint: .bottom)
			)
			VStack(spacing: 16) {
				Checkmark()
				Circle()
					.overlay(
						ZStack {
							Text("SC").foregroundColor(.white).font(.regular90)
							Circle()
								.stroke(Color.white, lineWidth: 3.0)
						}
				).foregroundColor(Color.clear)
					.frame(width: 240, height: 240)
			}.offset(x: 0, y: -50)
		}.edgesIgnoringSafeArea(.top)
			.onAppear(perform: {
				self.player.playSound()
				self.animationFlag.toggle()
			})
	}
}

struct Checkmark: View {
	@State var showFirstStroke: Bool = false
	@State var showSecondStroke: Bool = false
	@State var showCheckMark: Bool = false
	var body: some View {
		ZStack {
			Circle()
				.strokeBorder(Color.white, lineWidth: 2)
				.rotation3DEffect(.degrees(showFirstStroke ? 0 : 360), axis: (x: 1, y: 1, z: 1))
				.animation(Animation.easeInOut(duration: 0.8))
			Circle()
				.strokeBorder(Color.white, lineWidth: 2)
				.rotation3DEffect(.degrees(showSecondStroke ? 0 : 360), axis: (x: -1, y: 1, z: 1))
				.animation(Animation.easeInOut(duration: 0.8))
			Path { path in
				path.move(to: CGPoint(x: 25, y: 45))
				path.addLine(to: CGPoint(x: 25, y: 45))
				path.addLine(to: CGPoint(x: 40, y: 60))
				path.addLine(to: CGPoint(x: 70, y: 30))
			}//45 x 30
				.trim(from: 0, to: showCheckMark ? 1 : 0)
				.stroke(style: StrokeStyle.init(lineWidth: 6, lineCap: .round, lineJoin: .round))
				.foregroundColor(.white)
				.animation(Animation.easeInOut.delay(0.3))
		}
	.onAppear(perform: {
		self.showFirstStroke.toggle()
		self.showSecondStroke.toggle()
		self.showCheckMark.toggle()
	})
		.frame(width: 95, height: 90)
	}
}
