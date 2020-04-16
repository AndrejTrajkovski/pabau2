import Model
import SwiftUI
import ComposableArchitecture

enum FormBuilder {
	static func makeForm(cssFields: [CSSField]) -> some View {
		List {
			ForEach(cssFields, id: \.id, content: { (cssField: CSSField) in
				return makeSection(cssField: cssField)
			})
		}
	}

	static func makeSection(cssField: CSSField) -> some View {
		return Section(header: Text(cssField.title!),
									 content: {
										Text(cssField.cssClass.rawValue)
		})
	}
}
