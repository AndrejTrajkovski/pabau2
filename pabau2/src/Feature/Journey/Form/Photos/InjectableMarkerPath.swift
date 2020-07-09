//

import SwiftUI

struct RotationGestureView: View {
	@State var angle = Angle(degrees: 0.0)
	
	var rotation: some Gesture {
		RotationGesture()
			.onChanged { angle in
				self.angle = angle
		}
	}
	
	var body: some View {
		InjectableMarkerPath()
			.fill(Color.red)
			.frame(width: 50, height: 70)
			.rotationEffect(self.angle, anchor: UnitPoint.bottom)
			.gesture(rotation)
	}
}

struct InjectableMarkerPath: Shape {
	//	let color: Color
	func path(in rect: CGRect) -> Path {
		let circleRadius = rect.size.width / 2
		let bottomLineWidth: CGFloat = 5
		
		var path = Path()
		path.addArc(center: CGPoint(x: rect.size.width / 2,
																y: rect.size.height / 4),
								radius: circleRadius,
								startAngle: .degrees(0),
								endAngle: .degrees(360),
								clockwise: true)
		let leftPoint = CGPoint(x: rect.size.width / 2 - bottomLineWidth,
														y: rect.size.height / 2)
		path.addLine(to: leftPoint)
		path.addLine(to: CGPoint(x: rect.size.width / 2,
														 y: rect.size.height))
		let rightPoint = CGPoint(x: rect.size.width / 2 + bottomLineWidth,
														 y: rect.size.height / 2)
		path.addLine(to: rightPoint)
		path.closeSubpath()
		return path
	}
}

struct InjectableMarkerPath_Previews: PreviewProvider {
	static var previews: some View {
		RotationGestureView()
	}
}
