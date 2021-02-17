import Foundation
import Overture
import UIKit

public struct Heading: Equatable {
	
	public let value: AttributedOrText
	
	public init(value: AttributedOrText) {
		self.value = value
	}
}

public enum AttributedOrText: Equatable {
	case attributed(NSAttributedString)
	case text(String)
	
	public init(value: String) {
		if let html = attrHtml(value: wrapInParagraph(value: value)) {
			self = .attributed(html)
		} else {
			self = .text(value)
		}
	}
}

func attrHtml(value: String) -> NSAttributedString? {
	let data = value.data(using: .utf8)
	let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
		NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
		NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber.init(integerLiteral: Int(8))
	]
	return data.flatMap {
		return try? NSAttributedString.init(data: $0,
											options: options,
											documentAttributes: nil)
	}
}

public func wrapInParagraph(value: String, fontSize: Int = 17) -> String {
	"<span style=\"font-family: Helvetica; font-size: \(fontSize)\">\(value)</span>"
}

//let dataFromUtf8String = with(true, with(String.Encoding.utf8, curry(flip(String.data))))
//
//let readingOptions = [
//	NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
//	NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
//] as [NSAttributedString.DocumentReadingOptionKey : Any]
//
//let attrStringFromHtml =
//	with(nil,
//		 flip(
//			with(readingOptions,
//				 flip(curry(NSAttributedString.init(data:options:documentAttributes:)))
//			)
//		 ))
//
//let getHtml = chain(dataFromUtf8String, attrStringFromHtml)
