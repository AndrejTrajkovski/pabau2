import SwiftUI
import ComposableArchitecture
import UtilPackage

public enum PhotosFormAction {

}

struct PhotosForm: View {

	let store: Store<[JourneyPhotos], PhotosFormAction>

	var body: some View {
		CollectionView(data: strings, layout: flowLayout) {
			Text($0)
				.padding(10)
				.background(Color.gray)
		}
	}
}
