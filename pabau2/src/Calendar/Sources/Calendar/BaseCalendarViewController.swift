import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class BaseCalendarViewController: UIViewController {

	var cancellables: Set<AnyCancellable> = []

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		//fix this line for week view
	}

	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		JZWeekViewHelper.viewTransitionHandler(to: size, weekView: view as! JZLongPressWeekView)
	}

	@objc public func userDidFlipPage(_ weekView: JZBaseWeekView, isNextPage: Bool) {
		fatalError("override me")
	}

	public func presentAlert(_ date: Date,
							 _ anchorView: UIView,
							 _ weekView: JZLongPressWeekView,
							 onAddBookout: @escaping () -> Void,
							 onAddAppointment: @escaping () -> Void) {
		let alert = UIAlertController(title: date.toString(.dateTime(.short)),
									  message: nil,
									  preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction.init(title: "Add  Appointment", style: .default, handler: { _ in
			anchorView.removeFromSuperview()
			onAddAppointment()
		}))
		alert.addAction(UIAlertAction.init(title: "Add Bookout", style: .default, handler: { _ in
			anchorView.removeFromSuperview()
			onAddBookout()
		}))
		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: {_ in
			anchorView.removeFromSuperview()
		}))
		alert.popoverPresentationController?.sourceView = anchorView
		alert.popoverPresentationController?.sourceRect = anchorView.bounds
		present(alert, animated: true)
	}
    
    public func presentAlert(
        _ date: Date,
        _ anchorView: UIView,
        _ weekView: JZLongPressWeekView,
        onEditAppointment: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: date.toString(.dateTime(.short)),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "Edit Appointment", style: .default, handler: { _ in
            anchorView.removeFromSuperview()
            onEditAppointment()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: {_ in
            anchorView.removeFromSuperview()
        }))
        alert.popoverPresentationController?.sourceView = anchorView
        alert.popoverPresentationController?.sourceRect = anchorView.bounds
        present(alert, animated: true)
    }
}

extension BaseCalendarViewController: JZBaseViewDelegate {

	public func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
		print("initDateDidChange: ", initDate)
	}

	public func areNotSame(date1: Date, date2: Date) -> Bool {
		return date1.compare(toDate: date2, granularity: .day) != .orderedSame
	}
}

extension BaseCalendarViewController: JZLongPressViewDataSource {
	public func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
		let cell = BaseCalendarCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
		cell.layoutSubviews()
		cell.title.text = "New Appointment"
		cell.contentView.backgroundColor = UIColor(hex: 0xEEF7FF)
		cell.colorBlock.backgroundColor = UIColor(hex: 0x0899FF)
		return cell
	}
}
