import SwiftUI
import ComposableArchitecture
import Model
import Combine

protocol ClientCardListable {
	associatedtype Listable
	static func getList(clientId: Int) -> EffectWithResult<[Listable], RequestError>
}

extension Appointment: ClientCardListable {
	
	func makeElement() -> some View {
		HStack {
			Text("")
			VStack {
				Text(self.service?.name ?? "")
			}
		}
	}
	
	static func getList(clientId: Int) -> EffectWithResult<[Appointment], RequestError> {
		ClientsMockAPI().getAppointments(clientId: clientId)
	}
}

extension SavedPhoto: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[SavedPhoto], RequestError> {
		ClientsMockAPI().getPhotos(clientId: clientId)
	}
}

extension Financial: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[Financial], RequestError> {
		ClientsMockAPI().getFinancials(clientId: clientId)
	}
}

//extension FormData: ClientCardListable {
//	static public func getList(clientId: Int) -> EffectWithResult<[FormData], RequestError> {
//		ClientsMockAPI().getForms(type: self.template.formType, clientId: clientId)
//	}
//}

extension Document: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[Document], RequestError> {
		ClientsMockAPI().getDocuments(clientId: clientId)
	}
}

extension Communication: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[Communication], RequestError> {
		ClientsMockAPI().getCommunications(clientId: clientId)
	}
}

extension Model.Alert: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[Model.Alert], RequestError> {
		ClientsMockAPI().getAlerts(clientId: clientId)
	}
}

extension Note: ClientCardListable {
	static public func getList(clientId: Int) -> EffectWithResult<[Model.Alert], RequestError> {
		ClientsMockAPI().getAlerts(clientId: clientId)
	}
}
