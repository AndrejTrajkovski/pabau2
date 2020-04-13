import SwiftUI
import ComposableArchitecture

struct CheckInAnimation: View {
	@Binding var isRunningAnimation: Bool
	var player = Player()
	var body: some View {
		ZStack {
			Rectangle().fill(
				LinearGradient(gradient: .init(colors: [.checkInGradient1, .deepSkyBlue]), startPoint: .top, endPoint: .bottom)
			)
			VStack(spacing: 24) {
				Checkmark(animationDuration: self.animationDuration, onAnimationFinish: {
					self.isRunningAnimation = true
				})
				Circle()
					.overlay(
						ZStack {
							Text("SC").foregroundColor(.white).font(.regular90)
							Circle()
								.stroke(Color.white, lineWidth: 3.0)
						}
				).foregroundColor(Color.clear)
					.frame(width: 240, height: 240)
				Text("Checking-In").foregroundColor(.white).font(.regular24)
				Text("Hand over the tablet to the client").foregroundColor(.checkInSubtitle).font(.regular16)
			}.offset(x: 0, y: -50)
		}.edgesIgnoringSafeArea(.top)
			.onAppear(perform: {
				self.player.playSoundAndVibrate()
			})
	}
}

extension CheckInAnimation {
	var animationDuration: Double {
		#if DEBUG
			return 0.0
		#else
			return 1.0
		#endif
	}
}

struct Checkmark: View {
	let animationDuration: Double
	let onAnimationFinish: () -> Void
	@State var showFirstStroke: Bool = false
	@State var showSecondStroke: Bool = false
	@State var showCheckMark: Bool = false

	var body: some View {
		ZStack {
			Circle()
				.strokeBorder(Color.white, lineWidth: 2)
				.rotation3DEffect(.degrees(showFirstStroke ? 0 : 360), axis: (x: 1, y: 1, z: 1))
				.animation(Animation.easeInOut(duration: animationDuration))
			Circle()
				.strokeBorder(Color.white, lineWidth: 2)
				.rotation3DEffect(.degrees(showSecondStroke ? 0 : 360), axis: (x: -1, y: 1, z: 1))
				.animation(Animation.easeInOut(duration: animationDuration))
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
		DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
			self.onAnimationFinish()
		}
	})
		.frame(width: 95, height: 90)
	}
}
