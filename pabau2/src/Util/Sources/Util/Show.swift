
import Combine
import SwiftUI
#if !os(macOS)
public struct Show: ViewModifier {
    @Binding var isVisible: Bool
    @ViewBuilder
    public func body(content: Content) -> some View {
        if isVisible {
            content
        } else {
            content.hidden()
        }
    }
}

public extension View {
     func show(isVisible: Binding<Bool>) -> some View {
        ModifiedContent(content: self, modifier: Show(isVisible: isVisible))
    }
}
#endif
