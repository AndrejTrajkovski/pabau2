import SwiftUI
import ComposableArchitecture
import Util

public enum AddOrEditPhotosBtnAction {
	case addPhotos
	case editPhotos
}

private enum AddOrEdit {
	case add
	case edit
}

struct AddOrEditPhotosBtn: View {
	let store: Store<Bool, AddOrEditPhotosBtnAction>

	struct State: Equatable {
		fileprivate let addOrEdit: AddOrEdit
	}

	var body: some View {
		WithViewStore(self.store.scope(state: State.init)) { viewStore in
			SecondaryButton(self.btnText(viewStore.state.addOrEdit)) {
				viewStore.send(self.btnAction(viewStore.state.addOrEdit))
			}
		}
	}
	
	private func btnAction(_ addOrEdit: AddOrEdit) -> AddOrEditPhotosBtnAction {
		switch addOrEdit {
		case .add:
			return .addPhotos
		case .edit:
			return .editPhotos
		}
	}
	
	private func btnText(_ addOrEdit: AddOrEdit) -> String {
		switch addOrEdit {
		case .add:
			return Texts.addPhotos
		case .edit:
			return Texts.editPhotos
		}
	}
}

extension AddOrEditPhotosBtn.State {
	init(_ isPhotosArrayEmpty: Bool) {
		self.addOrEdit = isPhotosArrayEmpty ? .add : .edit
	}
}
