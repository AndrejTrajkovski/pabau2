
import SwiftUI

public struct EdgesFrame: ViewModifier {
    public func body(content: Content) -> some View {
        content.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}
extension View {
    public func toEdges() -> some View {
        self.modifier(EdgesFrame())
    }
}
