import Foundation
import SwiftUI
import Combine

public class ImageDownloader {
    
    func downloadSingleImage(urlString: String) -> AnyPublisher<UIImage, Never> {
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }
    
    func downloadImages(urlStrings: [String]) -> AnyPublisher<[UIImage], Never> {
        urlStrings
            .publisher
            .compactMap { URL(string: $0) }
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
            }
            .receive(on: RunLoop.main)
            .compactMap { $0.data }
            .compactMap { UIImage(data: $0) }
            .catch { _ in Empty() }
            .collect()
            .eraseToAnyPublisher()
    }
}
