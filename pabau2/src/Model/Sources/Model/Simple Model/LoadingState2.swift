import Foundation

public enum LoadingState2<T: Equatable>: Equatable {
	case loaded(T)
	case error(RequestError)
	case loading
	
	public mutating func update(_ result: Result<T, RequestError>) {
		switch result {
		case .success(let value):
			self = .loaded(value)
		case .failure(let error):
			self = .error(error)
		}
	}
}
