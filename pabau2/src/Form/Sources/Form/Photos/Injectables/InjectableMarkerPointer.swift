import SwiftUI
import Util

struct InjectableMarkerPlain: View {

	let wToHRatio: CGFloat
	let color: Color
	let isActive: Bool
	let increment: String

	var body: some View {
		GeometryReaderPatch { geo in
			VStack(spacing: 0) {
				InjectableMarkerCircle(
					increment: self.increment,
					color: self.color,
					isActive: self.isActive
				)
					.frame(height: geo.size.height * self.wToHRatio)
				InjectableMarkerPointer()
					.stroke(self.isActive ? Color.white : self.color)
					.frame(height: geo.size.height * (1 - self.wToHRatio))
					.offset(x: 0, y: self.isActive ? 0 : -1)
			}
		}
	}
}

struct InjectableMarkerPointer: Shape {
	func path(in rect: CGRect) -> Path {
		let bottomLineWidth: CGFloat = 3
		var path = Path()
		let leftPoint = CGPoint(x: rect.size.width / 2 - bottomLineWidth,
														y: 0)
		path.move(to: leftPoint)
		path.addLine(to: CGPoint(x: rect.size.width / 2,
														 y: rect.size.height))
		let rightPoint = CGPoint(x: rect.size.width / 2 + bottomLineWidth,
														 y: 0)
		path.addLine(to: rightPoint)
		path.closeSubpath()
		return path
	}
}

struct InjectableMarkerCircle: View {
	let increment: String
	let color: Color
	let isActive: Bool
	var body: some View {
		ZStack {
			Circle()
			.overlay(
				Group {
					if isActive {
						Circle()
							.stroke(Color.white)
					}
				}
			).foregroundColor(color)
			Text(increment)
				.foregroundColor(.white)
				.font(.bold12)
		}
	}
}

struct InjectableMarkerPath_Previews: PreviewProvider {
	static var previews: some View {
		InjectableMarkerPlain(wToHRatio: 0.7,
													color: .blue,
													isActive: false,
													increment: String(0.25))
			.frame(height: 70)
		.background(Color.green)
	}
}
