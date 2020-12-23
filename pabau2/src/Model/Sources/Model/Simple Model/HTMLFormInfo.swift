import Foundation

struct HTMLFormInfo: Codable {
//	let formId:
	let templateId: HTMLFormTemplate.ID
	let name: String
	let status: Bool
}
