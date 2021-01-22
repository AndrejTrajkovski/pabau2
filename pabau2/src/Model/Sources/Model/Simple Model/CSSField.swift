//
// CSSField.swift

import Foundation
import Tagged
public struct CSSField: Equatable, Identifiable {
	
	public typealias ID = Tagged<CSSField, String>

	public let id: ID

	public var cssClass: CSSClass

	public let _required: Bool

	public let title: String?
	
	init?(id: Self.ID, formStructure: _FormStructure) {
		do{
			let cssClass = try CSSClass.init(_formStructure: formStructure)
			self.id = id
			self._required = Bool(formStructure.formStructureRequired) ?? false
			self.title = formStructure.title
			self.cssClass = cssClass
		} catch {
			return nil
		}
	}
}



extension CSSField.ID {
	
	init(idx: Int, cssField: _FormStructure) {
		let key = cssField.keyString()
		self.init(idx: idx, string: key)
	}
	
	init(idx: Int, string: String) {
		self = Tagged(rawValue: String(idx) + string.lowercased())
	}
}
