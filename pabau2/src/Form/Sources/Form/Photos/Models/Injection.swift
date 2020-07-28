import CoreGraphics
import SwiftUI

public struct Injection: Equatable, Identifiable {
	public let id: UUID = UUID()
	var units: Double
	var position: CGPoint
	var injectableId: Int
	var angle: Angle = .init(degrees: .zero)
}
