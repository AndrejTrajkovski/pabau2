import Foundation
import Model
import Util

public struct AftercareState: Equatable, Identifiable {
	public let id: Step.Id
	
	public init (
		id: Step.Id,
        images: [ImageModel],
		aftercares: [AftercareTemplate],
		recalls: [AftercareTemplate]
	) {
		self.id = id
        self.images = images
        self.aftercares = AftercareBoolSectionState.init(templates: aftercares)
		self.recalls = AftercareBoolSectionState.init(templates: recalls)
	}
    
    let images: [ImageModel]
    var selectedProfileImageIdx: Int? = nil
    var selectedShareImgeIdx: Int? = nil
	var aftercares: AftercareBoolSectionState
	var recalls: AftercareBoolSectionState
    var getAftercareLS: LoadingState = .loading
}

extension AftercareState {
    
    var profile: SingleSelectImages {
        get {
            SingleSelectImages(images: images, selectedIdx: selectedProfileImageIdx)
        }
        set {
            self.selectedProfileImageIdx = newValue.selectedIdx
        }
    }
    
    var share: SingleSelectImages {
        get {
            SingleSelectImages(images: images, selectedIdx: selectedShareImgeIdx)
        }
        set {
            self.selectedShareImgeIdx = newValue.selectedIdx
        }
    }
}
