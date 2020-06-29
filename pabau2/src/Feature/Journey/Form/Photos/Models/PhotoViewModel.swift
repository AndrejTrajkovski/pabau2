import Model
import PencilKit
import ComposableArchitecture

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

extension Dictionary where Key == InjectableId, Value == Injection {
	var totals: TotalInjAndUnits {
		self.values.reduce(into: TotalInjAndUnits()) {
			$0.totalInj += 1
			$0.totalUnits += $1.units
		}
	}
}

public struct PhotoViewModel: Equatable {
	let basePhoto: Photo
	var drawing: PKDrawing?
	var isPrivate: Bool = false
	var tags: [String] = []
	var injections: [InjectableId: [Injection]] = [:]
	
	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.drawing = nil
	}

	init (_ newPhoto: NewPhoto) {
		self.basePhoto = .new(newPhoto)
		self.drawing = nil
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
