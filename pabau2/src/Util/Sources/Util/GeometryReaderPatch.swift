import SwiftUI

//iOS 14 bug
//https://swiftui-lab.com/geometryreader-bug/
public struct GeometryReaderPatch<Content: View>: View {
	public var content: (GeometryProxy) -> Content

	@inlinable public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
		self.content = content
	}

	public var body: some View {
		GeometryReader { geometryProxy in
			content(geometryProxy)
				.frame(width: geometryProxy.size.width,
					   height: geometryProxy.size.height,
					   alignment: .center)
		}
	}
}
