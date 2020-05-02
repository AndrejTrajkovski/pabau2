//
//  CollectionView.swift
//
//
//  Created by Stefano Bertagno on 30/12/2019.
//

import SwiftUI
import UIKit

/// Layout representation of the `CollectionView`.
public struct CollectionViewLayout {
	/// The scrolliing direction. Defaults to `.horizontal`.
	public var axis: Axis = .horizontal
	/// Whether it should show scrolling indicators or not. Defaults to `true`.
	public var showsIndicators: Bool = true
	/// Bounces.
	public var alwaysBounces: Bool = false

	/// The interitem spacing. Defaults to `nil`.
	public var interItemSpacing: NSCollectionLayoutSpacing?
	/// The inter group spacing. Defaults to `10`.
	public var interGroupSpacing: CGFloat = 10
	/// The item size.
	public var itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1),
																											heightDimension: .fractionalHeight(1))
	/// The group size.
	public var groupSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(100),
																											 heightDimension: .absolute(100))
	/// The item content inset. Defaults to `.zero`.
	public var itemContentInset: NSDirectionalEdgeInsets = .zero
	/// The item edge spacing. Defaults to `nil`.
	public var itemEdgeSpacing: NSCollectionLayoutEdgeSpacing?

	/// Update.
	public var transform: ((UICollectionView) -> Void)?
}

/// A basic `UICollectionView` wrapper.
public struct CollectionView<Content: View>: UIViewControllerRepresentable {
	public typealias UIViewControllerType = UICollectionViewController
	public typealias Coordinator = CollectionCoordinator<Content>

	/// The actual ids.
	var identifiers: [Int]
	/// The actual content.
	var content: [Content]
	
	var selectedIdx: Int

	/// The layout info.
	var layout: CollectionViewLayout = .init()

	// MARK: Lifecycle
	/// Init with `data`.
//	public init<C, ID>(_ data: C, id: KeyPath<C.Element, ID>, @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, ID: Hashable {
//		self.identifiers = data.map { $0[keyPath: id].hashValue }
//		self.content = data.map(content)
//	}
	/// Init with hashable `data`.
	public init<C>(_ data: C,
								 _ selectedIdx: Int,
								 @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, C.Element: Hashable {
		self.identifiers = data.map { $0.hashValue }
		self.content = data.map(content)
		self.selectedIdx = selectedIdx
	}
	/// Init with identifiable data.
//	public init<C>(_ data: C, @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, C.Element: Identifiable {
//		self.identifiers = data.map { $0.id.hashValue }
//		self.content = data.map(content)
//	}

	// MARK: Accessory
	/// Update layout.
	public func layout(_ transform: (inout CollectionViewLayout) -> Void) -> Self {
		var copy = self
		transform(&copy.layout)
		return copy
	}
	/// Update `layout.axis`.
	public func axis(_ axis: Axis) -> Self { layout { $0.axis = axis }}
	/// Update `layout.showsIndicators`.
	public func indicators(_ showsIndicators: Bool) -> Self { layout { $0.showsIndicators = showsIndicators }}
	/// Update `layout.alwaysBounces`.
	public func bounce(_ alwaysBounces: Bool) -> Self { layout { $0.alwaysBounces = alwaysBounces }}
	/// Update `layout.interItemSpacing`.
	public func itemSpace(_ interitemSpacing: NSCollectionLayoutSpacing?) -> Self {
		layout { $0.interItemSpacing = interitemSpacing }
	}
	/// Update `layout.interGroupSpacing`.
	public func groupSpace(_ intergroupSpacing: CGFloat) -> Self { layout { $0.interGroupSpacing = intergroupSpacing }}
	/// Update `layout.itemSize`.
	public func itemSize(_ size: NSCollectionLayoutSize) -> Self { layout { $0.itemSize = size }}
	/// Update `layout.groupSize`.
	public func groupSize(_ size: NSCollectionLayoutSize) -> Self { layout { $0.groupSize = size }}
	/// Update `layout.itemContentInset`.
	public func itemContentInset(_ contentInset: NSDirectionalEdgeInsets) -> Self { layout { $0.itemContentInset = contentInset }}
	/// Update `layout.edgeSpacing`.
	public func itemEdgeSpacing(_ edgeSpacing: NSCollectionLayoutEdgeSpacing?) -> Self { layout { $0.itemEdgeSpacing = edgeSpacing }}
	/// Update `layout.transform`.
	public func introspect(_ transform: @escaping (UICollectionView) -> Void) -> Self { layout { $0.transform = transform }}

	// MARK: UIViewControllerRepresentable
	public func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView<Content>>) -> UICollectionViewController {
		// update layout.
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = self.layout.axis == .horizontal ? .horizontal : .vertical
		let item = NSCollectionLayoutItem(layoutSize: self.layout.itemSize)
		item.contentInsets = self.layout.itemContentInset
		item.edgeSpacing = self.layout.itemEdgeSpacing
		let group = self.layout.axis == .horizontal
			? NSCollectionLayoutGroup.vertical(layoutSize: self.layout.groupSize, subitems: [item])
			: NSCollectionLayoutGroup.horizontal(layoutSize: self.layout.groupSize, subitems: [item])
		group.interItemSpacing = .fixed(CGFloat(0))
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = self.layout.interGroupSpacing
		let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
		// update collection.
		let controller = UICollectionViewController(collectionViewLayout: layout)
		controller.collectionView.alwaysBounceHorizontal = self.layout.alwaysBounces && self.layout.axis == .horizontal
		controller.collectionView.alwaysBounceVertical = self.layout.alwaysBounces && self.layout.axis == .vertical
//		controller.collectionView.preservesSuperviewLayoutMargins = true
		controller.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		controller.collectionView.backgroundColor = .clear
		controller.collectionView.dataSource = context.coordinator
		controller.collectionView.showsHorizontalScrollIndicator = self.layout.showsIndicators && self.layout.axis == .horizontal
		controller.collectionView.showsVerticalScrollIndicator = self.layout.showsIndicators && self.layout.axis == .vertical
		controller.collectionView.clipsToBounds = true
		print(controller.collectionView.translatesAutoresizingMaskIntoConstraints)
		self.layout.transform?(controller.collectionView)
//		controller.collectionView.translatesAutoresizingMaskIntoConstraints = false
//		controller.collectionView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//		controller.collectionView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//		controller.collectionView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
		return controller
	}
	public func updateUIViewController(_ uiViewController: UICollectionViewController,
																		 context: UIViewControllerRepresentableContext<CollectionView<Content>>) {
		context.coordinator.zipped = Array(zip(identifiers, content))
		uiViewController.collectionView.reloadData()
		uiViewController.collectionView.scrollToItem(at:
			IndexPath(row: selectedIdx, section: 0),
																								 at: .centeredHorizontally, animated: true)
//		uiViewController.collectionView.frame.size =
//			CGSize(
//				width: uiViewController.collectionView.frame.size.width,
//				height: 50)
		print(uiViewController.collectionView.frame.size.height)
	}

	// MARK: Coordinator
	public func makeCoordinator() -> CollectionCoordinator<Content> {
		.init(collectionView: self)
	}

	/// The `BasicCollectionView` coordinator.
	public class CollectionCoordinator<Content: View>: NSObject, UICollectionViewDataSource {

		var zipped: [(Int, Content)]

		init(collectionView: CollectionView<Content>) {
			self.zipped = Array(zip(collectionView.identifiers, collectionView.content))
		}

		public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { zipped.count }
		public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else {
				fatalError("Invalid collection view cell.")
			}
			// update cell.
			let value = zipped[indexPath.item]
			guard cell.identifier != value.0 else { return cell }
			cell.contentView.subviews.forEach { $0.removeFromSuperview() }
			let controller = UIHostingController(rootView: value.1)
			guard let container = controller.view else {
				fatalError("Invalid container view for cell.")
			}
			// update container.
			container.backgroundColor = .clear
			container.frame = .zero
			container.translatesAutoresizingMaskIntoConstraints = true
			container.clipsToBounds = true
			container.frame = cell.contentView.bounds
			container.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin]
			cell.contentView.addSubview(container)
			cell.identifier = value.0
			return cell
		}
	}
}

extension CollectionDifference.Change {
	/// Offset.
	var offset: Int {
		switch self {
		case .insert(let offset, _, _): return offset
		case .remove(let offset, _, _): return offset
		}
	}
}

final class CollectionViewCell: UICollectionViewCell {
	/// The primary key.
	var identifier: Int?
}
