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
			if let toastState = viewStore.state {
				toast(isPresenting: .constant(true),
					  alert: { AlertToast(displayMode: toastState.mode,
										  type: toastState.type,
										  title: toastState.title,
										  subTitle: toastState.subTitle, custom: nil)
					  }
				)
			} else {
				self
			}
		}
	}
}
