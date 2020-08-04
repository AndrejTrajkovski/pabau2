import SwiftUI
import ComposableArchitecture
import Model
import Combine
import Util

struct ClientCardChild<T: ClientCardListable>: View {
	let listable: T
	let list: [T.Listable]
	var body: some View {
		List {
			ForEach(list.indices) { idx in
				self.listable.makeView(element: self.list[idx])
			}
		}
	}
}

public struct ClientCardChildState<T: Equatable>: Equatable {
	var activeItem: T
	var activeItemLoadingState: LoadingState
}

public protocol ClientCardModel {}

public protocol ClientCardListable {
	associatedtype Listable: ClientCardModel
	associatedtype SomeView: View
	static func getList(clientId: Int) -> EffectWithResult<[Listable], RequestError>
	func makeView(element: Listable) -> SomeView
}

extension ClientCardListable where Listable == Appointment {
	static func getList(clientId: Int) -> EffectWithResult<[Appointment], RequestError> {
		return ClientsMockAPI().getAppointments(clientId: clientId)
	}
	func makeView(element: Appointment) -> some View {
		return HStack {
			Text(element.service?.name ?? "some appointment with no service")
		}
	}
}

//struct ListableAppointment: ClientCardListable {
//	static func getList(clientId: Int) -> EffectWithResult<[Appointment], RequestError> {
//		return ClientsMockAPI().getAppointments(clientId: clientId)
//	}
//	func makeView(element: Appointment) -> some View {
//		return HStack {
//			Text(element.service?.name ?? "some appointment with no service")
//		}
//	}
//}

extension Appointment: ClientCardModel {}
extension SavedPhoto: ClientCardModel {}
