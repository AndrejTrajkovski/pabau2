import Foundation
import Tagged

public struct CSSField: Equatable, Identifiable {

	public let id: CSSFieldID

	public var cssClass: CSSClass

	public let _required: Bool

	public let title: String?
	
	init?(id: CSSFieldID, formStructure: _FormStructure) {
		do{
			let cssClass = try CSSClass.init(_formStructure: formStructure, fieldId: id)
			print("fieldId: \(id)")
			self.id = id
			self._required = Bool(formStructure.formStructureRequired) ?? false
			self.title = formStructure.getLabelTitle()
			self.cssClass = cssClass
		} catch {
			return nil
		}
	}
}

public struct CSSFieldID: Hashable, Equatable {
	
	public typealias FakeID = Tagged<CSSFieldID, String>
	
	let index: Int
	let fakeId: FakeID
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(index)
		hasher.combine(fakeId)
	}
	
	init(idx: Int, fakeId: String) {
		self.index = idx
		self.fakeId = CSSFieldID.FakeID(rawValue: fakeId)
	}
}
