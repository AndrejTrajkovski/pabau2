import UIKit
import Model
import JZCalendarWeekView
import SwiftDate

public class CalendarViewController: UIViewController {
	
	weak var calendarView: LongPressView!
	static let cellId = "CalendarCell"
	var appointments = [CalAppointment]()
	let today = Date() - 8.days
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupCalendarView()
		calendarView.setupCalendar(numOfDays: 1,
															 setDate: today,
															 allEvents: [today:[]],
															 scrollType: .pageScroll,
															 scrollableRange: (nil, nil))
		loadDummyRequest()
	}

	func setupCalendarView() {
		let calendarView = LongPressView.init(frame: .zero)
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(calendarView)
    NSLayoutConstraint.activate([
        calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
				calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
				calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0),
    ])
		calendarView.longPressDelegate = self
		calendarView.longPressDataSource = self
		calendarView.longPressTypes = [.addNew, .move]
		calendarView.addNewDurationMins = 120
		calendarView.moveTimeMinInterval = 15
		self.calendarView = calendarView
	}
	
	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarView)
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		loadDummyRequest()
	}
	
	func loadDummyRequest() {
		let request = URLRequest.init(url: URL(string: Self.calTestUrl)!)
				let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
					if let data = data {
						do {
							let decoder = JSONDecoder()
							let decodedResponse = try decoder.decode(CalendarResponse.self, from: data)
							DispatchQueue.main.async {
								self.appointments = decodedResponse.appointments
								self.reloadData()
							}
						} catch {
							print(error)
						}
					} else {
						print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
					}
				}.resume()
	}
	
	func reloadData() {
		let events = self.appointments.map(IntervalsAdapter.makeAppointmentEvent(_:))
		let sorted = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		self.calendarView.forceReload(reloadEvents: sorted)
	}
}

extension CalendarViewController {
	static let calTestUrl = "https://crm.pabau.com/OAuth2/appointments/get_appointments_v1.php?user_id=76101&company=3470&api_key=c05c7ef55c70b1d1d7674245f2b2f20184&app_version=4.5.2&start_date=2020-09-01&end_date=2020-09-01&location_id=2503,7282,7283,2668&user_ids=76101,49452,59828,23034,72367,59826,59830,54673,59991,50688,51502,34498,47967,76047,76037,59986,19277,52102,58230,55813,77249,55057,76020,76022,58146,79142,59989,37711,51484,76975,51889,52105,52804,36361,78339,49128,49134,49137,34264,49143,72551,55918,52096,78393,72466,53086,51736,77996,43612,78103,37048,52825,48396,49509,55825,42427,25386,78497,75031,72036,60008,77991,76967,76041,42316,51886,76040,49092,19283,79400,72040,80042,59824,53050,72651,79017,78195,76104,76106,76105,76107,76039,76972,76038,52546,81785,55645,41962,34291%27"
}

extension CalendarViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {
	
	func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
		let newApp = AllDayEvent(id: UUID().uuidString, title: "New Event", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
															 location: "Melbourne", isAllDay: false)
		
		if viewModel.eventsByDate[startDate.startOfDay] == nil {
			viewModel.eventsByDate[startDate.startOfDay] = [AllDayEvent]()
		}
		viewModel.events.append(newEvent)
		viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
		weekView.forceReload(reloadEvents: viewModel.eventsByDate)
	}
	
	func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		guard let event = editingEvent as? AllDayEvent else { return }
		let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
		let selectedIndex = viewModel.events.firstIndex(where: { $0.id == event.id })!
		viewModel.events[selectedIndex].startDate = startDate
		viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
		
		viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
		weekView.forceReload(reloadEvents: viewModel.eventsByDate)
	}
	
	func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
		if let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EventCell {
			view.titleLabel.text = "New Event"
			return view
		}
		return UIView()
	}
}
