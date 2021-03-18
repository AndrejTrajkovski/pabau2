import Foundation
import Model
import SwiftUI
import ComposableArchitecture
import Util
import SharedComponents

struct LoadingStore<State, Action, Content>: View where Content: View, State: Equatable {
	
	let store: Store<LoadingState2<State>, Action>
	private let content: (ViewStore<LoadingState2<State>, Action>) -> Content
	
	public init<IfContent>(
		_ store: Store<LoadingState2<State>, Action>,
		then ifContent: @escaping (Store<State, Action>) -> IfContent
	) where Content == _ConditionalContent<IfContent, _ConditionalContent<ErrorViewStore<RequestError>, LoadingView>> {
		self.init(store,
				  then: ifContent,
				  error: ErrorViewStore.init(store:),
				  loading: LoadingView.init
		)
	}
	
	public init<IfContent, ErrorContent, LoadingContent>(
		_ store: Store<LoadingState2<State>, Action>,
		then ifContent: @escaping (Store<State, Action>) -> IfContent,
		error errorContent: @escaping (Store<RequestError, Never>) -> ErrorContent,
		loading loadingContent: @escaping () -> LoadingContent
	) where Content == _ConditionalContent<IfContent, _ConditionalContent<ErrorContent, LoadingContent>> {
		self.init(store,
				  then: ifContent,
				  error: errorContent,
				  errorPath: { _ in fatalError() },
				  loading: loadingContent)
	}
	
	public init<IfContent, ErrorContent, LoadingContent, ErrorAction>(
		_ store: Store<LoadingState2<State>, Action>,
		then ifContent: @escaping (Store<State, Action>) -> IfContent,
		error errorContent: @escaping (Store<RequestError, ErrorAction>) -> ErrorContent,
		errorPath: @escaping (ErrorAction) -> Action,
		loading loadingContent: @escaping () -> LoadingContent
	) where Content == _ConditionalContent<IfContent, _ConditionalContent<ErrorContent, LoadingContent>> {
		self.store = store
		self.content = { viewStore in
			if case .loaded(let state) = viewStore.state {
				return ViewBuilder.buildEither(first:
												ifContent(store.scope(state: { extract(case: LoadingState2.loaded, from: $0) ?? state }
												)
												)
				)
			} else {
				let errorOrLoading: () -> _ConditionalContent<ErrorContent, LoadingContent> = {
					if case .error(let error) = viewStore.state {
						let errorStore = store.scope(state: {
							extract(case: LoadingState2.error, from: $0) ?? error
						}, action: errorPath)
						
						return ViewBuilder.buildEither(first:
														errorContent(errorStore)
						)
					} else {
						return ViewBuilder.buildEither(second: loadingContent())
					}
				}
				
				return ViewBuilder.buildEither(second: errorOrLoading())
				
			}
		}
	}
	
	func errorOrLoading<ErrorContent: View, LoadingContent: View, State, ErrorAction>(
		_ store: (Store<RequestError, ErrorAction>),
		state: LoadingState2<State>,
		error errorContent: (Store<RequestError, ErrorAction>) -> ErrorContent,
		loading loadingContent: () -> LoadingContent
	) -> _ConditionalContent<ErrorContent, LoadingContent> {
		if case .error(let error) = state {
			return ViewBuilder.buildEither(first:
											errorContent(store)
			)
		} else {
			return ViewBuilder.buildEither(second: loadingContent())
		}
	}
	
//	func errorOrLoadingView(error: RequestError,
//							loadingTitle: String) -> _ConditionalContent<ErrorView<RequestError>, LoadingView<EmptyView>> {
//		if case .error(let error) = state {
//			return ViewBuilder.buildEither(first: ErrorView(error: error) )
//		} else {
//			return ViewBuilder.buildEither(second: LoadingView.init(title: loadingTitle,
//																	bindingIsShowing: .constant(true), content: EmptyView()))
//		}
//	}
//
//	func errorOrLoading(state: LoadingState2<State>,
//						loadingContent: () -> LoadingView<EmptyView>) -> _ConditionalContent<LoadingView<EmptyView>, ErrorView<RequestError>> {
//		if case .error(let error) = state {
//			return ViewBuilder.buildEither(second: ErrorView(error: error) )
//		} else {
//			return ViewBuilder.buildEither(first: loadingContent())
//		}
//	}
	
	var body: some View {
		WithViewStore(store) { viewStore in
			content(viewStore)
		}
	}
}

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

struct LoadingView: View {
	var body: some View {
		Text("Loading...").frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}


public struct ErrorView<E: Error>: View where E: CustomStringConvertible {
	
	public init(error: E) {
		self.error = error
	}
	
	let error: E
	
	public var body: some View {
		GeometryReaderPatch { geometry in
			Text("Error: \(error.description)")
				.frame(width: geometry.size.width / 2,
					   height: geometry.size.height / 5)
				.background(Color.white)
				.foregroundColor(Color.blue)
				.cornerRadius(20)
		}
	}
}
