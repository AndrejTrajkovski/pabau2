import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture
import Form

public enum CheckInDoctorAction {
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
	case completeJourney(CompleteJourneyBtnAction)
	case stepsView(StepsViewAction)
	case footer(FooterButtonsAction)
}

struct CheckInBody: View {
	let store: Store<CheckInViewState, CheckInBodyAction>
	
	var body: some View {
		print("check in body body")
		return GeometryReaderPatch { geo in
			VStack(spacing: 8) {
				StepsCollectionView(store:
					self.store.scope(
						state: { $0.forms }, action: { .stepsView($0) })
				).frame(height: 80)
				Divider()
					.frame(width: geo.size.width)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
				FormPager(store: self.store)
					/*
					IfLetStore(self.store
					.scope(state: { $0.selectedForm?.form },
					action: { .updateForm(Indexed(self.viewStore.state.selectedIndex, $0))
					}), then: FormWrapper.init(store:))
					.padding(.bottom,
					self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					*/
					.padding([.bottom], 32)
					.padding([.top], 32)
				Spacer()
//				if self.keyboardHandler.keyboardHeight == 0
//				{
//					FooterButtons(store: self.store.scope(
//						state: { $0.footer }, action: { .footer($0) }
//					))
//					.frame(maxWidth: 500)
//					.padding(8)
//				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}
