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
