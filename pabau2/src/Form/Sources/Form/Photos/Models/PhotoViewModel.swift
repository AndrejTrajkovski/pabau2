import Model
import PencilKit
import ComposableArchitecture
import Util

public typealias InjectableId = Int
//public struct InjectionsByInjectable: Equatable, Identifiable {
//	public var id: Int { return injectableId }
//	var injectableId: InjectableId
//	var injections: IdentifiedArrayOf<Injection>
//	var totals: TotalInjAndUnits {
//		self.injections.reduce(into: TotalInjAndUnits()) {
//			$0.totalInj += 1
//			$0.totalUnits += $1.units
//		}
//	}
//}

public struct PhotoViewModel: Equatable {
	public let basePhoto: Photo
    var drawing: Data = PKDrawing().dataRepresentation()
	var isPrivate: Bool = false
	var tags: [String] = []
	var injections: [InjectableId: IdentifiedArrayOf<Injection>] = [:]
	var chosenInjectionId: UUID?
    var savePhotoState: LoadingState = .initial
    var canvasSize: CGSize = .zero

	public init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
	}

	init (_ newPhoto: NewPhoto) {
		self.basePhoto = .new(newPhoto)
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
