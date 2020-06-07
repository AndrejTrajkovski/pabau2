import UIKit
class CameraOverlayView: UIView {

//	var xBtn: UIButton!
//	var editBtn: UIButton!
//	var tagBtn: UIButton!
//	var nudityBtn: UIButton!
	var frontBackSwitchBtn: UIButton!
	var flashBtn: UIButton!
	var stenscilsCollectionView: UICollectionView!
	var topBtnsStack: UIStackView!

	var showHideStencilsBtn: UIButton!
	var takePhotoBtn: UIButton!
	var openGalleryBtn: UIButton!
	var bottomBtnsStack: UIStackView!

	override init(frame: CGRect) {
		super.init(frame: frame)

		let bottomBtnsStack = UIStackView()
		bottomBtnsStack.axis = NSLayoutConstraint.Axis.vertical
		bottomBtnsStack.distribution = UIStackView.Distribution.equalSpacing
		bottomBtnsStack.alignment = UIStackView.Alignment.center
		bottomBtnsStack.spacing = 32.0

		let showHideStensiclsBtn = UIButton(type: .custom)
		showHideStensiclsBtn.setImage(UIImage(named: "ico-journey-upload-photos-stencils"), for: .normal)
		self.showHideStencilsBtn = showHideStensiclsBtn

		let takePhotoBtn = UIButton(type: .custom)
		takePhotoBtn.setImage(UIImage(named: "ico-journey-upload-photos-take-a-photo"), for: .normal)
		self.takePhotoBtn = takePhotoBtn

		let openGalleryBtn = UIButton(type: .custom)
		openGalleryBtn.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
		self.openGalleryBtn = openGalleryBtn

		bottomBtnsStack.addArrangedSubview(showHideStensiclsBtn)
		bottomBtnsStack.addArrangedSubview(takePhotoBtn)
		bottomBtnsStack.addArrangedSubview(openGalleryBtn)

		self.bottomBtnsStack = bottomBtnsStack

		self.addSubview(bottomBtnsStack)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

import SwiftUI

struct CameraOverlay: View {
	var body: some View {
		VStack {
			TopButtons()
			Spacer()
			StencilsCollection()
			BottomButtons()
		}
		.buttonStyle(CameraButtonStyle())
	}
}

private struct TopButtons: View {
	var body: some View {
		HStack {
			Button.init(action: { }, label: {
				Image(systemName: "xmark.circle.fill")
			})
			Spacer()
//			Button.init(action: { }, label: {
//				Text("Edit")
//			})
			Button.init(action: { }, label: {
				Image(systemName: "tag")
			})
			Button.init(action: { }, label: {
				Image(systemName: "eye.slash")
			})
			Button.init(action: { }, label: {
				Image(systemName: "camera")
			})
			Button.init(action: { }, label: {
				Image(systemName: "bolt")
			})
		}.padding()
	}
}

private struct StencilsCollection: View {
	var body: some View {
		HStack {
			ForEach(1..<10) { index in
				Image("dummy\(index)")
				.resizable()
				.frame(width: 62, height: 74)
			}
		}.padding()
	}
}

private struct BottomButtons: View {
	var body: some View {
		HStack {
			Button.init(action: { }, label: {
				Image(systemName: "wand.and.stars")
			})
			Button.init(action: { }, label: {
				Image("ico-journey-upload-photos-take-a-photo")
			})
			Button.init(action: { }, label: {
				Image(systemName: "photo.on.rectangle")
			})
		}.padding()
	}
}

private struct CameraButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(width: 44, height: 44)
			.foregroundColor(Color.white)
			.background(Color.black.opacity(0.2))
			.clipShape(Circle())
	}
}
