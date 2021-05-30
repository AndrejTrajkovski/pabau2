import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import CoreDataModel
import Foundation
import ToastAlert
import Combine
import AlertToast

public struct AppointmentDetails: View {
    public let store: Store<AppDetailsState, AppDetailsAction>
    @ObservedObject var viewStore: ViewStore<AppDetailsState, AppDetailsAction>
    public init(store: Store<AppDetailsState, AppDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            AppDetailsHeader(store: self.store)
            Spacer().frame(height: 32)
            AppDetailsInfo(store: self.store)
            AppDetailsButtons(store: self.store)
                .fixedSize(horizontal: false, vertical: true)
			AddEventPrimaryBtn(title: Texts.addService) {
				self.viewStore.send(.addService)
			}
		}
		.addEventWrapper(
			onXBtnTap: { self.viewStore.send(.close) }
		)
		.toast(store: store.scope(state: \.toast))
	}
}
