import SwiftUI
import ComposableArchitecture
import AlertToast

public struct ToastTimerId: Hashable {
	public init () {}
}

public struct ToastState<Action>: Equatable {
	public init(mode: AlertToast.DisplayMode, type: AlertToast.AlertType, title: String? = nil, subTitle: String? = nil) {
		self.mode = mode
		self.type = type
		self.title = title
		self.subTitle = subTitle
	}
	
	public var mode: AlertToast.DisplayMode
	public var type: AlertToast.AlertType
	public var title: String?
	public var subTitle: String?
}

extension View {
	
    public func toast<Action>(store: Store<ToastState<Action>?, Action>) -> some View {
            WithViewStore(store) { viewStore in
                toast(isPresenting: .constant(viewStore.state != nil),
                      duration: 1,
                      alert: { AlertToast(displayMode: viewStore.state?.mode ?? .banner(.slide),
                                          type: viewStore.state?.type ?? .regular,
                                          title: viewStore.state?.title,
                                          subTitle: viewStore.state?.subTitle,
                                          custom: nil)
                     }
                )
            }
    }

}
