import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

struct CheckInAnimation: View {
	
	let animationDuration: Double
	let appointment: Appointment
	
	var body: some View {
		VStack(spacing: 24) {
			Checkmark(animationDuration: self.animationDuration)
			JourneyTransitionCircle(appointment: appointment)
		}.offset(x: 0, y: -50)
		.gradientView()
		.edgesIgnoringSafeArea(.top)
	}
}

struct JourneyTransitionCircle: View {
	let appointment: Appointment
	var body: some View {
		JourneyTransitionView(title: Texts.checkInDesc,
							  description: Texts.checkInTitle,
							  content: {
								Circle()
									.overlay(
										ZStack {
											ListCellAvatarView(appointment: self.appointment,
															   font: .regular90,
															   bgColor: .clear)
												.foregroundColor(.white)
											Circle()
												.stroke(Color.white, lineWidth: 3.0)
										}
									).foregroundColor(Color.clear)
									.frame(width: 214, height: 214)
							  })
	}
}

struct Checkmark: View {
	let animationDuration: Double
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
		})
		.frame(width: 95, height: 90)
	}
}

public let checkInAnimationDuration: Double = {
	#if DEBUG
	return 2.0
	#else
	return 2.0
	#endif
}()
