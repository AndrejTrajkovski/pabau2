// swiftlint:disable identifier_name
import SwiftUI
public struct RoundedCorners: View {
	
	public init(color: Color = .black,
							tl: CGFloat = 0.0,
							tr: CGFloat = 0.0,
							bl: CGFloat = 0.0,
							br: CGFloat = 0.0) {
		self.color = color
		self.tl = tl
		self.tr = tr
		self.bl = bl
		self.br = br
	}
	
	public var color: Color = .black
	public var tl: CGFloat = 0.0
	public var tr: CGFloat = 0.0
	public var bl: CGFloat = 0.0
	public var br: CGFloat = 0.0
	
	public var body: some View {
		GeometryReader { geometry in
			Path { path in
				
				let w = geometry.size.width
				let h = geometry.size.height
				
				// We make sure the redius does not exceed the bounds dimensions
				let tr = min(min(self.tr, h/2), w/2)
				let tl = min(min(self.tl, h/2), w/2)
				let bl = min(min(self.bl, h/2), w/2)
				let br = min(min(self.br, h/2), w/2)
				
				path.move(to: CGPoint(x: w / 2.0, y: 0))
				path.addLine(to: CGPoint(x: w - tr, y: 0))
				path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
				path.addLine(to: CGPoint(x: w, y: h - br))
				path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
				path.addLine(to: CGPoint(x: bl, y: h))
				path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
				path.addLine(to: CGPoint(x: 0, y: tl))
				path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
			}
			.fill(self.color)
		}
	}
}
// swiftlint:enable identifier_name
