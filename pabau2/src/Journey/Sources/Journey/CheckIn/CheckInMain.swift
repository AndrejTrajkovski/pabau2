import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture
import CasePaths
import Form

//public enum CheckInMainAction {
//	case checkInBody(CheckInBodyAction)
//	case complete
//	case topView(TopViewAction)
//}

//struct CheckInMain: View {
//	let store: Store<CheckInViewState, CheckInMainAction>
//
//	var body: some View {
//		VStack (spacing: 0) {
//			TopView(store: self.store
//						.scope(state: { $0 },
//							   action: { .topView($0) }))
//			CheckInBody(store: self.store.scope(
//							state: { $0 },
//							action: { .checkInBody($0) }))
//			Spacer()
//		}
//	}
//}
