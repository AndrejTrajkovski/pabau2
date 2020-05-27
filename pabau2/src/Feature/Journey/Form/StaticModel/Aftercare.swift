public struct Aftercare: Equatable {
	var profile: SingleSelectImages
	var share: SingleSelectImages
	var aftercares: [AftercareOption]
	var recalls: [Recall]
}

public struct AftercareOption: Hashable, Identifiable {
	let title: String
	let channel: AftercareChannel
	var isSelected: Bool
	public var id: String { return title }
	public init (_ title: String,
							 _ channel: AftercareChannel,
							 _ isSelected: Bool = false) {
		self.title = title
		self.channel = channel
		self.isSelected = isSelected
	}
}

public enum AftercareChannel: Equatable {
	case sms
	case email
}
