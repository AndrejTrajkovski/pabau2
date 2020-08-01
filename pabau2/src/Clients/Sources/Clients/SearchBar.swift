import SwiftUI

//TODO: Move to Util package
struct SearchBar: UIViewRepresentable {
	let placeholder: String?
	@Binding var text: String
	class Coordinator: NSObject, UISearchBarDelegate {
		@Binding var text: String
		init(text: Binding<String>) {
			_text = text
		}
		func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
			text = searchText
		}
		func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
			searchBar.resignFirstResponder()
		}
		func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
			searchBar.resignFirstResponder()
		}
	}
	func makeCoordinator() -> SearchBar.Coordinator {
		return Coordinator(text: $text)
	}
	
	func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
		let searchBar = UISearchBar(frame: .zero)
		searchBar.placeholder = placeholder
		searchBar.delegate = context.coordinator
		searchBar.autocapitalizationType = .none
		return searchBar
	}
	func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
		uiView.text = text
	}
}
