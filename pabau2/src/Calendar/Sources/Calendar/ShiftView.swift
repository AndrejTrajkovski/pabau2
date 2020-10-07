import UIKit

class ShiftView: UICollectionReusableView {
	public override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.green

	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
