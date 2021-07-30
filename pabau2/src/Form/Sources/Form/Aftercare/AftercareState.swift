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
    public var selectedProfileImageIdx: Int? = nil
    public var selectedShareImgeIdx: Int? = nil
	public var aftercares: AftercareBoolSectionState
	public var recalls: AftercareBoolSectionState
    
    public func selectedProfileImageId() -> ImageModel.ID? {
        selectedProfileImageIdx.map { images[$0].id }
    }
    
    public func selectedShareImageId() -> ImageModel.ID? {
        selectedShareImgeIdx.map { images[$0].id }
    }
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
