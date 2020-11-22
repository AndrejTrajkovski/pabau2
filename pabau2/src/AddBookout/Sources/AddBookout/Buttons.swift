import SwiftUI
import ComposableArchitecture
import AddEventControls
import Util

enum ButtonsActions {
	case onDelete
	case onRepeat
	case onReschedule
}

struct Buttons: View {
	
	var body: some View {
		HStack(spacing: 0) {
			TimeSlotButton(image: "minus.circle", title: Texts.delete, onTap: {
//				ButtonsActions.onDelete
			})
			TimeSlotButton(image: "arrow.2.circlepath", title: Texts.repeat, onTap: {
//				ButtonsActions.onRepeat
			})
			TimeSlotButton(image: "arrowshape.turn.up.right", title: Texts.reschedule, onTap: {
//				ButtonsActions.onReschedule
			})
		}
	}
}
