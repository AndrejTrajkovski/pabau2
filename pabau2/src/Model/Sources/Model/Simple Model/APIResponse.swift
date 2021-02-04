import Combine
import ComposableArchitecture

struct APIResponse<T: Decodable>: Decodable {
	public let result: Result<T, RequestError>
	
	enum CodingKeys: CodingKey {
		case success
		case message
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let success = try container.decode(Bool.self, forKey: .success)
		if success {
			let value = try T.init(from: decoder)
			self.result = .success(value)
		} else {
			let message = try container.decode(String.self, forKey: .message)
			self.result = .failure(RequestError.apiError(message))
		}
	}
}
