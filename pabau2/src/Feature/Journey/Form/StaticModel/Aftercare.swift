
public struct Aftercare: Equatable {
	var profileImages: [String]
	var shareImages: [String]
	var aftercares: [AftercareOption]
	var recalls: [Recall]
}

struct AftercareOption: Equatable {
	let title: String
	let channel: AftercareChannel
	var isSelected: Bool
	
	public init (_ title: String,
							 _ channel: AftercareChannel,
							 _ isSelected: Bool = false) {
		self.title = title
		self.channel = channel
		self.isSelected = isSelected
	}
}

enum AftercareChannel: Equatable {
	case sms
	case email
}
