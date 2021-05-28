import SwiftUI
import ComposableArchitecture


public struct ToastState: Equatable {
    public static func == (lhs: ToastState, rhs: ToastState) -> Bool {
        return lhs.isPresented == rhs.isPresented
    }
    
    public var isPresented: Bool = false
    public var onDismiss: (() -> ())?
    
    public init(onDismiss: (() -> ())? = nil) {
        self.onDismiss = onDismiss
    }
}

public enum ToastAction: Equatable {
    case onDisplay
    case onDismiss
    
}

public typealias ToastEnvironment = (String)

public let toastReducer = Reducer<ToastState, ToastAction, ToastEnvironment>.init { state, action, _ in
    struct TimerId: Hashable {}
    switch action {
    case .onDisplay:
        state.isPresented = true
        if state.onDismiss == nil {
            return Effect.timer(id: TimerId(), every: 3, on: RunLoop.main)
                .map { _ in ToastAction.onDismiss }
        }
    case .onDismiss:
        state.isPresented = false
        return .cancel(id: TimerId())
    }
    return .none
}


extension View {
    func toast<Content>(state: ToastState?,
                         @ViewBuilder content: () -> Content) -> some View {
        self.modifier(AlertToastModifier())
    }
}

public struct AlertToastModifier: ViewModifier {
    
    public func body(content: Content) -> some View {
        content
            .background(Color.red)
            .padding()
    }
}
