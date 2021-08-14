import Foundation
import Tagged

public struct CSSField: Equatable, Identifiable {

	public let id: CSSFieldID

	public var cssClass: CSSClass

	public let _required: Bool
	
	public let title: String?
	
	init?(id: CSSFieldID, formStructure: _FormStructure, formTemplateId: String) {
		do{
			guard let cssClass = try CSSClass.init(_formStructure: formStructure, fieldId: id) else {
                return nil
            }
			self.id = id
			self._required = Bool(formStructure.formStructureRequired) ?? false
			self.title = formStructure.getLabelTitle()
			self.cssClass = cssClass
		} catch {
            print("css field error")
            print(error)
			return nil
		}
	}
}

public struct CSSFieldID: Hashable, Equatable {
	
	public typealias FakeID = Tagged<CSSFieldID, String>
	
	let index: Int
	let fakeId: FakeID
	//Might be needed for the hash, in case of two forms have same id and index for field, to prevent crash in double ForEach
	let formTemplateId: String
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(index)
		hasher.combine(fakeId)
		hasher.combine(formTemplateId)
	}
	
	init(idx: Int, fakeId: String, formTemplateId: String) {
		self.index = idx
		self.fakeId = CSSFieldID.FakeID(rawValue: fakeId)
		self.formTemplateId = formTemplateId
	}
}
