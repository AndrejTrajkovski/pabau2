import UIKit

public class CalendarViewController: UICollectionViewController {
	
	static let cellId = "CalendarCell"
	
	var dataSource: [Int: [Int: IntervalInfo]] {
		didSet {
			(self.collectionView.collectionViewLayout as! CalendarLayout).dataSource = dataSource
		}
	}

	init(dataSource: [Int: [Int: IntervalInfo]]) {
		self.dataSource = dataSource
		let flowLayout = CalendarLayout(intervalHeight: 30,
																		sectionWidth: 100,
																		intervalMinutes: 15,
																		dataSource: dataSource)
		super.init(collectionViewLayout: flowLayout)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.register(BaseCalendarCell.self,
														forCellWithReuseIdentifier: Self.cellId)
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.reloadData()
	}
}

// MARK: UICollectionViewDataSource
extension CalendarViewController {
	public override func numberOfSections(in collectionView: UICollectionView) -> Int {
		dataSource.count
	}
	
	public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let res = dataSource[section]?.count ?? 0
		print("numberOfItemsInSection \(section) : \(res)")
		return res
	}

	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		print("cell for row \(indexPath)")
		guard var cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: Self.cellId,
			for: indexPath
			) as? BaseCalendarCell else {
				fatalError()
		}
		CalendarCellFactory().configure(cell: &cell,
																		patientName: "Andrej Trajkovski",
																		serviceName: "Botox",
																		serviceColor: UIColor.green,
																		lighterServiceColor: UIColor.green.makeLighter(),
																		roomName: "")
		return cell
	}
}
