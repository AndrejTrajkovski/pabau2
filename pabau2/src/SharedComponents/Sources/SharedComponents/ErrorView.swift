import ComposableArchitecture
import SwiftUI
import Util

public struct ErrorViewStore<E: Error>: View where E: CustomStringConvertible & Equatable {
	
	public init(store: Store<E, Never>) {
		self.store = store
	}
	
	let store: Store<E, Never>
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			ErrorView(error: viewStore.state)
		}
	}
}

public struct ErrorView<E: Error>: View {
	
	let error: E
	
	public init(error: E) {
		self.error = error
	}
	
	public var body: some View {
		RawErrorView(description: (error as CustomStringConvertible).description)
	}
}

public struct RawErrorView: View {
	
	public init(description: String) {
		self.description = description
	}
	
	let description: String
	
	public var body: some View {
		GeometryReaderPatch { geometry in
			Text("Error: \(description)")
				.frame(width: geometry.size.width / 2,
					   height: geometry.size.height / 5)
				.background(Color.white)
				.foregroundColor(Color.blue)
				.cornerRadius(20)
		}
	}
}
