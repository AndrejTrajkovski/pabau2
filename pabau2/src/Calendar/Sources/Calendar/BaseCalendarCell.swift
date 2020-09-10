import UIKit
import JZCalendarWeekView

struct CellViewModel {
	let blockColor: UIColor
	let bgColor: UIColor
	let title: String
	let subtitle: String
}

class BaseCalendarCell: JZLongPressEventCell {

	override func prepareForReuse() {
		title.text = ""
		subtitle.text = ""
		colorBlock.backgroundColor = UIColor.clear
//		setNeedsUpdateConstraints()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(title)
		contentView.addSubview(subtitle)
		contentView.addSubview(colorBlock)
		addColorBlockConstraints()
		addTitleLabelConstraints()
		addSubtitleLabelConstraints()
		title.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .vertical)
//		subtitle.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .vertical)
	}
	
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		if subtitle.frame.maxY >= bounds.maxY {
////				title.setContentCompressionResistancePriority(UILayoutPriority(300), for: .vertical)
//				subtitle.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//			setNeedsUpdateConstraints()
//			super.layoutSubviews()
//		}
//	}

	override class var requiresConstraintBasedLayout: Bool {
		true
	}

	let title: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 20)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
	}()

	let subtitle: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 14)
		label.textColor =  .white
		label.clipsToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
	}()

	let colorBlock: UIView = {
		let block = UIView()
		block.translatesAutoresizingMaskIntoConstraints = false
		return block
	}()

	func addColorBlockConstraints() {
		NSLayoutConstraint(item: colorBlock,
						attribute: .leading,
						relatedBy: .equal,
						toItem: contentView,
						attribute: .leading,
						multiplier: 1,
						constant: 0).isActive = true
		NSLayoutConstraint(item: colorBlock,
						attribute: .top,
						relatedBy: .equal,
						toItem: contentView,
						attribute: .top,
						multiplier: 1.0,
						constant: 0).isActive = true
		NSLayoutConstraint(item: colorBlock,
						attribute: .height,
						relatedBy: .equal,
						toItem: contentView,
						attribute: .height,
						multiplier: 1.0,
						constant: 0.0).isActive = true
		NSLayoutConstraint(item: colorBlock,
						attribute: .width,
						relatedBy: .equal,
						toItem: nil,
						attribute: .notAnAttribute,
						multiplier: 1.0,
						constant: 5.0).isActive = true
	}

	func addTitleLabelConstraints() {
		NSLayoutConstraint(item: title,
						attribute: .leading,
						relatedBy: .equal,
						toItem: colorBlock,
						attribute: .trailing,
						multiplier: 1.0,
						constant: 8.0).isActive = true
		NSLayoutConstraint(item: title,
						attribute: .top,
						relatedBy: .equal,
						toItem: contentView,
						attribute: .top,
						multiplier: 1.0,
						constant: 8.0).isActive = true
		NSLayoutConstraint(item: title,
						attribute: .trailing,
						relatedBy: .equal,
						toItem: contentView,
						attribute: .trailing,
						multiplier: 1.0,
						constant: -8.0).isActive = true
	}

	func addSubtitleLabelConstraints() {
		NSLayoutConstraint(item: subtitle,
						attribute: .leading,
						relatedBy: .equal,
						toItem: title,
						attribute: .leading,
						multiplier: 1.0,
						constant: 0.0).isActive = true
		NSLayoutConstraint(item: subtitle,
						attribute: .top,
						relatedBy: .equal,
						toItem: title,
						attribute: .bottom,
						multiplier: 1.0,
						constant: 4.0).isActive = true
		NSLayoutConstraint(item: subtitle,
						attribute: .trailing,
						relatedBy: .equal,
						toItem: title,
						attribute: .trailing,
						multiplier: 1.0,
						constant: 0).isActive = true
		let bottom = NSLayoutConstraint(item: subtitle,
																		attribute: .bottom,
																		relatedBy: .equal,
																		toItem: contentView,
																		attribute: .bottom,
																		multiplier: 1.0,
																		constant: 0)
		bottom.isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
