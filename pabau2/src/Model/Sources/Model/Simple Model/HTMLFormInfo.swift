import Foundation

public struct HTMLFormInfo: Codable, Identifiable, Equatable {
	public let id: HTMLForm.ID
	public let name: String
	public let type: FormType
}
