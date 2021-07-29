import Foundation
import Model

public struct AftercareState: Equatable, Identifiable {
	public let id: Step.Id
	
	public init (
		id: Step.Id,
		profile: SingleSelectImages,
		share: SingleSelectImages,
		aftercares: [AftercareTemplate],
		recalls: [AftercareTemplate]
	) {
		self.id = id
		self.profile = profile
		self.share = share
        self.aftercares = AftercareBoolSectionState.init(templates: aftercares)
		self.recalls = AftercareBoolSectionState.init(templates: recalls)
	}

	var profile: SingleSelectImages
	var share: SingleSelectImages
	var aftercares: AftercareBoolSectionState
	var recalls: AftercareBoolSectionState
}
