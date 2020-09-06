import UIKit

class CalendarLayout: UICollectionViewLayout {
	let verticalItemSpacing: Int = 1
	let intervalMinutes: Int
	let sectionWidth: Int
	let intervalHeight: Int
	let numberOfIntervals: Int

	var dataSource: CalendarCells
	var cached: [UICollectionViewLayoutAttributes] = []

	init(intervalHeight: Int,
			 sectionWidth: Int,
			 intervalMinutes: Int,
			 dataSource: CalendarCells) {
		self.intervalHeight = intervalHeight
		self.sectionWidth = sectionWidth
		self.intervalMinutes = intervalMinutes
		self.numberOfIntervals = 24 * ( 60 / intervalMinutes )
		self.dataSource = dataSource
		super.init()
	}

	override func prepare() {
		super.prepare()
		for sectionIdx in 0..<(collectionView?.numberOfSections ?? 0) {
			var lastFrame = CGRect.zero
			for itemIdx in 0..<(collectionView?.numberOfItems(inSection: sectionIdx) ?? 0) {
				let blocksCount = dataSource[sectionIdx][itemIdx].intervalsCount
				let idxP = IndexPath(item: itemIdx, section: sectionIdx)
				let attr = UICollectionViewLayoutAttributes(forCellWith: idxP)
				let newY = lastFrame.maxY + CGFloat(verticalItemSpacing)
				let itemWidth = sectionWidth / 2
				let isEven = itemIdx % 2 == 0
				let sectionX = sectionIdx * sectionWidth
				let newX = isEven ? sectionX / 2 : sectionX
				let yExtraInset = (blocksCount - 1) * verticalItemSpacing
				let newHeight = (intervalHeight * blocksCount) + yExtraInset
				let newFrame = CGRect.init(x: newX,
																	 y: Int(newY),
																	 width: itemWidth,
																	 height: newHeight)
				attr.frame = newFrame
				cached.append(attr)
				lastFrame = newFrame
				print(newFrame)
			}
		}
	}

	override var collectionViewContentSize: CGSize {
		let width = (collectionView?.numberOfSections ?? 0) * (sectionWidth + 1)
		let height = numberOfIntervals * (intervalHeight + 1)
		return CGSize(width: width, height: height)
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return cached.first(where: {
			$0.indexPath == indexPath
		})
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		guard let collectionView = collectionView else { return false }
		return !newBounds.size.equalTo(collectionView.bounds.size)
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return cached.filter {
			rect.intersects($0.frame)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
