import SwiftUI

struct AftercareImageCell: View {
	
	let imageUrl: String
	
	var body: some View {
		ZStack {
			Image(imageUrl)
				.resizable()
		}
	}
}
