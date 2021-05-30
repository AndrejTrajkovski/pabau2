import SwiftUI
import ComposableArchitecture

struct ToastTimerId: Hashable {}

public struct ToastState: Equatable {
	public init() { }
    public var isPresented: Bool = false
	
	public mutating func present() -> Effect<ToastAction, Never> {
		isPresented = true
		return Effect.timer(id: ToastTimerId(), every: 3, on: RunLoop.main)
			.map { _ in ToastAction.dismiss }
	}
}

public enum ToastAction: Equatable {
    case dismiss
}

public typealias ToastEnvironment = ()

public let toastReducer = Reducer<ToastState, ToastAction, ToastEnvironment>.init { state, action, _ in
	
    switch action {
    case .dismiss:
        state.isPresented = false
        return .cancel(id: ToastTimerId())
    }
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
