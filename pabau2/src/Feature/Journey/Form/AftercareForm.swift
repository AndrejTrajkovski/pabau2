import SwiftUI
import ComposableArchitecture
import Util
import ASCollectionView

public enum AftercareAction {
	case aftercares(Indexed<ToggleAction>)
	case recalls(Indexed<ToggleAction>)
	case profile(SingleSelectImagesAction)
	case share(SingleSelectImagesAction)
}

public let aftercareReducer: Reducer<Aftercare, AftercareAction, Any> = (
	.combine(
		aftercareOptionReducer.forEach(
			state: \Aftercare.aftercares,
			action: /AftercareAction.aftercares,
			environment: { $0 }
		),
		recallReducer.forEach(
			state: \Aftercare.recalls,
			action: /AftercareAction.recalls,
			environment: { $0 }
		),
		singleSelectImagesReducer.pullback(
			state: \Aftercare.profile,
			action: /AftercareAction.profile,
			environment: { $0 }
		),
		singleSelectImagesReducer.pullback(
			state: \Aftercare.share,
			action: /AftercareAction.share,
			environment: { $0 })
	)
)

struct AftercareForm: View {
	let store: Store<Aftercare, AftercareAction>
	@ObservedObject var viewStore: ViewStore<Aftercare, AftercareAction>
	init(store: Store<Aftercare, AftercareAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	var body: some View {
		ASCollectionView {
			ASCollectionViewSection(
				id: 0,
				data: self.viewStore.state.profile.images,
				dataID: \.self) { imageUrl, context in
					GridCell(title: imageUrl.title,
									 isSelected: self.viewStore.state.profile.isSelected(url: imageUrl))
						.onTapGesture {
							self.viewStore.send(.profile(.didSelectIdx(context.index)))
					}
			}
			.sectionHeader {
				AftercareHeader(Texts.setProfilePhoto)
			}
			ASCollectionViewSection(
				id: 1,
				data: self.viewStore.state.share.images,
				dataID: \.self) { imageUrl, context in
					GridCell(title: imageUrl.title,
									 isSelected: self.viewStore.state.share.isSelected(url: imageUrl))
						.onTapGesture {
							self.viewStore.send(.share(.didSelectIdx(context.index)))
					}
			}
			.sectionHeader { AftercareHeader(Texts.sharePhoto) }
			ASCollectionViewSection(
				id: 2,
				data: self.viewStore.state.aftercares,
				dataID: \.self) { aftercare, context in
					AftercareCell(type: .init(channel: aftercare.channel),
												title: aftercare.title,
												value: Binding.init(
													get: { aftercare.isSelected },
													set: { self.viewStore
														.send(.aftercares(Indexed(context.index, ToggleAction.setTo($0)))) })
					)
			}
			.sectionHeader { AftercareHeader(Texts.sendAftercareQ) }
		}.layout { sectionID in
			switch sectionID {
			case 0, 1:
				// Here we use one of the provided convenience layouts
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 2.5,
										 lineSpacing: 2.5)
			case 2:
				return
					.list(itemSize: .absolute(60))
			default:
				fatalError()
			}
		}
		.scrollIndicatorsEnabled(horizontal: false, vertical: false)
		.navigationBarTitle("")
		.navigationBarBackButtonHidden(true)
		.navigationBarHidden(true)
	}
}

struct AftercareHeader: View {
	let title: String
	init (_ title: String) {
		self.title = title
	}
	var body: some View {
		Text(title)
			.font(.bold24)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding([.top, .bottom], 16)
	}
}
