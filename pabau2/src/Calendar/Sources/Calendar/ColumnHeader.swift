import UIKit
import Util

open class ColumnHeader: UICollectionReusableView {
	
	func update(title: String,
				subtitle: String,
				color: UIColor) {
		self.title.text = title
		self.subtitle.text = subtitle
		self.colorCircle.backgroundColor = color
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(title)
		addSubview(subtitle)
		addSubview(colorCircle)
		addcolorCircleConstraints()
		addTitleLabelConstraints()
		addSubtitleLabelConstraints()
//		title.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .vertical)
	}
	
	open override class var requiresConstraintBasedLayout: Bool {
		true
	}
	
	let title: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.textAlignment = .center
		return label
	}()
	
	let subtitle: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 10)
		label.textColor = UIColor.lightGray
		label.clipsToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.textAlignment = .center
		return label
	}()
	
	let colorCircle: UIView = {
		let circle = UIView()
		circle.layer.cornerRadius = circle.frame.size.width/2
		circle.clipsToBounds = true
		circle.translatesAutoresizingMaskIntoConstraints = false
		return circle
	}()
	
	func addcolorCircleConstraints() {
		NSLayoutConstraint(item: colorCircle,
						   attribute: .centerY,
						   relatedBy: .equal,
						   toItem: subtitle,
						   attribute: .centerY,
						   multiplier: 1,
						   constant: 0).isActive = true
//		NSLayoutConstraint(item: colorCircle,
//						   attribute: .leading,
//						   relatedBy: .greaterThanOrEqual,
//						   toItem: self,
//						   attribute: .leading,
//						   multiplier: 1,
//						   constant: 4).isActive = true
		let leading = NSLayoutConstraint(item: colorCircle,
										 attribute: .trailing,
										 relatedBy: .equal,
										 toItem: subtitle,
										 attribute: .leading,
										 multiplier: 1.0,
										 constant: -4)
		leading.isActive = true
		NSLayoutConstraint(item: colorCircle,
						   attribute: .height,
						   relatedBy: .equal,
						   toItem: colorCircle,
						   attribute: .width,
						   multiplier: 1.0,
						   constant: 0.0).isActive = true
		NSLayoutConstraint(item: colorCircle,
						   attribute: .width,
						   relatedBy: .equal,
						   toItem: nil,
						   attribute: .notAnAttribute,
						   multiplier: 1.0,
						   constant: 5.0).isActive = true
	}
	
	func addTitleLabelConstraints() {
		NSLayoutConstraint(item: title,
						   attribute: .top,
						   relatedBy: .equal,
						   toItem: self,
						   attribute: .top,
						   multiplier: 1.0,
						   constant: 4.0).isActive = true
		NSLayoutConstraint(item: title,
						   attribute: .trailing,
						   relatedBy: .equal,
						   toItem: self,
						   attribute: .trailing,
						   multiplier: 1.0,
						   constant: -8.0).isActive = true
		NSLayoutConstraint(item: title,
						   attribute: .centerX,
						   relatedBy: .equal,
						   toItem: self,
						   attribute: .centerX,
						   multiplier: 1.0,
						   constant: 0).isActive = true
	}

	func addSubtitleLabelConstraints() {
		NSLayoutConstraint(item: subtitle,
						   attribute: .centerX,
						   relatedBy: .equal,
						   toItem: self,
						   attribute: .centerX,
						   multiplier: 1.0,
						   constant: 0).isActive = true
		NSLayoutConstraint(item: subtitle,
						   attribute: .top,
						   relatedBy: .equal,
						   toItem: title,
						   attribute: .bottom,
						   multiplier: 1.0,
						   constant: 4.0).isActive = true
		subtitle.setContentHuggingPriority(UILayoutPriority(rawValue: 1000.0), for: .horizontal)
//		let bottom = NSLayoutConstraint(item: subtitle,
//										attribute: .bottom,
//										relatedBy: .equal,
//										toItem: self,
//										attribute: .bottom,
//										multiplier: 1.0,
//										constant: 0)
//		bottom.isActive = true
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
