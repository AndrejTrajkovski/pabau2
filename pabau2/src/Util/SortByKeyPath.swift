public extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { aaa, bbb in
            return aaa[keyPath: keyPath] < bbb[keyPath: keyPath]
        }
    }
}
