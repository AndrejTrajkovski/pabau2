import SwiftUI
import ComposableArchitecture
import Util

struct CheckInAnimation: View {
	@Binding var isRunningAnimation: Bool
	var player = Player()
	var body: some View {
			VStack(spacing: 24) {
				Checkmark(animationDuration: self.animationDuration, onAnimationFinish: {
					self.isRunningAnimation = true
				})
				JourneyTransitionView(title: Texts.checkInDesc,
															description: Texts.checkInTitle,
															circleContent: { Text("SC").font(.regular90)})
			}.offset(x: 0, y: -50)
				.gradientView()
				.edgesIgnoringSafeArea(.top)
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
			return 2.0
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
