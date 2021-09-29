import Foundation
import Model
import Util
import ComposableArchitecture

public struct AftercareState: Equatable, Identifiable {
	public let id: Step.Id
	
	public init (
		id: Step.Id,
		aftercares: [AftercareTemplate],
		recalls: [AftercareTemplate]
	) {
		self.id = id
        self.aftercares = AftercareBoolSectionState.init(templates: aftercares)
		self.recalls = AftercareBoolSectionState.init(templates: recalls)
        self.images = []
	}
    
    public var images: IdentifiedArrayOf<SavedPhoto>
    public var selectedProfileImageId: SavedPhoto.ID? = nil
    public var selectedShareImgeId: SavedPhoto.ID? = nil
	public var aftercares: AftercareBoolSectionState
	public var recalls: AftercareBoolSectionState
}

extension AftercareState {
    
    var profile: SingleSelectImages {
        get {
            SingleSelectImages(images: images, selectedId: selectedProfileImageId)
        }
        set {
            self.selectedProfileImageId = newValue.selectedId
        }
    }
    
    var share: SingleSelectImages {
        get {
            SingleSelectImages(images: images, selectedId: selectedShareImgeId)
        }
        set {
            self.selectedShareImgeId = newValue.selectedId
        }
    }
}
