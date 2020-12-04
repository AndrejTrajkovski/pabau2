import SwiftUI

public extension AnyTransition {
	static var moveAndFade: AnyTransition {
		AnyTransition.move(edge: .trailing)
	}
}
