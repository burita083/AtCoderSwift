//
//  main.swift
//  AtCoderSwift
//
//  Created by burita083 on 2020/08/25.
//  Copyright © 2020 burita083. All rights reserved.
//

import Foundation // Needed for ComparisonResult (used privately)

/// An array that keeps its elements sorted at all times.
public struct SortedArray<Element> {
    /// The backing store
    fileprivate var _elements: [Element]
    
    public typealias Comparator<A> = (A, A) -> Bool
    
    /// The predicate that determines the array's sort order.
    fileprivate let areInIncreasingOrder: Comparator<Element>
    
    /// Initializes an empty array.
    ///
    /// - Parameter areInIncreasingOrder: The comparison predicate the array should use to sort its elements.
    public init(areInIncreasingOrder: @escaping Comparator<Element>) {
        self._elements = []
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    /// Initializes the array with a sequence of unsorted elements and a comparison predicate.
    public init<S: Sequence>(unsorted: S, areInIncreasingOrder: @escaping Comparator<Element>) where S.Element == Element {
        let sorted = unsorted.sorted(by: areInIncreasingOrder)
        self._elements = sorted
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    /// Initializes the array with a sequence that is already sorted according to the given comparison predicate.
    ///
    /// This is faster than `init(unsorted:areInIncreasingOrder:)` because the elements don't have to sorted again.
    ///
    /// - Precondition: `sorted` is sorted according to the given comparison predicate. If you violate this condition, the behavior is undefined.
    public init<S: Sequence>(sorted: S, areInIncreasingOrder: @escaping Comparator<Element>) where S.Element == Element {
        self._elements = Array(sorted)
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    /// Inserts a new element into the array, preserving the sort order.
    ///
    /// - Returns: the index where the new element was inserted.
    /// - Complexity: O(_n_) where _n_ is the size of the array. O(_log n_) if the new
    /// element can be appended, i.e. if it is ordered last in the resulting array.
    @discardableResult
    public mutating func insert(_ newElement: Element) -> Index {
        let index = insertionIndex(for: newElement)
        // This should be O(1) if the element is to be inserted at the end,
        // O(_n) in the worst case (inserted at the front).
        _elements.insert(newElement, at: index)
        return index
    }
    
    /// Inserts all elements from `elements` into `self`, preserving the sort order.
    ///
    /// This can be faster than inserting the individual elements one after another because
    /// we only need to re-sort once.
    ///
    /// - Complexity: O(_n * log(n)_) where _n_ is the size of the resulting array.
    public mutating func insert<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        _elements.append(contentsOf: newElements)
        _elements.sort(by: areInIncreasingOrder)
    }
}

extension SortedArray where Element: Comparable {
    /// Initializes an empty sorted array. Uses `<` as the comparison predicate.
    public init() {
        self.init(areInIncreasingOrder: <)
    }
    
    /// Initializes the array with a sequence of unsorted elements. Uses `<` as the comparison predicate.
    public init<S: Sequence>(unsorted: S) where S.Element == Element {
        self.init(unsorted: unsorted, areInIncreasingOrder: <)
    }
    
    /// Initializes the array with a sequence that is already sorted according to the `<` comparison predicate. Uses `<` as the comparison predicate.
    ///
    /// This is faster than `init(unsorted:)` because the elements don't have to sorted again.
    ///
    /// - Precondition: `sorted` is sorted according to the `<` predicate. If you violate this condition, the behavior is undefined.
    public init<S: Sequence>(sorted: S) where S.Element == Element {
        self.init(sorted: sorted, areInIncreasingOrder: <)
    }
}

extension SortedArray: RandomAccessCollection {
    public typealias Index = Int
    
    public var startIndex: Index { return _elements.startIndex }
    public var endIndex: Index { return _elements.endIndex }
    
    public func index(after i: Index) -> Index {
        return _elements.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return _elements.index(before: i)
    }
    
    public subscript(position: Index) -> Element {
        return _elements[position]
    }
}

extension SortedArray {
    /// Like `Sequence.filter(_:)`, but returns a `SortedArray` instead of an `Array`.
    /// We can do this efficiently because filtering doesn't change the sort order.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SortedArray<Element> {
        let newElements = try _elements.filter(isIncluded)
        return SortedArray(sorted: newElements, areInIncreasingOrder: areInIncreasingOrder)
    }
}

extension SortedArray: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(String(describing: _elements)) (sorted)"
    }
    
    public var debugDescription: String {
        return "<SortedArray> \(String(reflecting: _elements))"
    }
}

// MARK: - Removing elements. This is mostly a reimplementation of part `RangeReplaceableCollection`'s interface. `SortedArray` can't conform to `RangeReplaceableCollection` because some of that protocol's semantics (e.g. `append(_:)` don't fit `SortedArray`'s semantics.
extension SortedArray {
    /// Removes and returns the element at the specified position.
    ///
    /// - Parameter index: The position of the element to remove. `index` must be a valid index of the array.
    /// - Returns: The element at the specified index.
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        return _elements.remove(at: index)
    }
    
    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        _elements.removeSubrange(bounds)
    }
    
    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeSubrange(_ bounds: ClosedRange<Int>) {
        _elements.removeSubrange(bounds)
    }
    
    // Starting with Swift 4.2, CountableRange and CountableClosedRange are typealiases for
    // Range and ClosedRange, so these methods trigger "Invalid redeclaration" errors.
    // Compile them only for older compiler versions.
    // swift(3.1): Latest version of Swift 3 under the Swift 3 compiler.
    // swift(3.2): Swift 4 compiler under Swift 3 mode.
    // swift(3.3): Swift 4.1 compiler under Swift 3 mode.
    // swift(3.4): Swift 4.2 compiler under Swift 3 mode.
    // swift(4.0): Swift 4 compiler
    // swift(4.1): Swift 4.1 compiler
    // swift(4.1.50): Swift 4.2 compiler in Swift 4 mode
    // swift(4.2): Swift 4.2 compiler
    #if !swift(>=4.1.50)
    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeSubrange(_ bounds: CountableRange<Int>) {
        _elements.removeSubrange(bounds)
    }
    
    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeSubrange(_ bounds: CountableClosedRange<Int>) {
        _elements.removeSubrange(bounds)
    }
    #endif
    
    /// Removes the specified number of elements from the beginning of the
    /// array.
    ///
    /// - Parameter n: The number of elements to remove from the array.
    ///   `n` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeFirst(_ n: Int) {
        _elements.removeFirst(n)
    }
    
    /// Removes and returns the first element of the array.
    ///
    /// - Precondition: The array must not be empty.
    /// - Returns: The removed element.
    /// - Complexity: O(_n_), where _n_ is the length of the collection.
    @discardableResult
    public mutating func removeFirst() -> Element {
        return _elements.removeFirst()
    }
    
    /// Removes and returns the last element of the array.
    ///
    /// - Precondition: The collection must not be empty.
    /// - Returns: The last element of the collection.
    /// - Complexity: O(1)
    @discardableResult
    public mutating func removeLast() -> Element {
        return _elements.removeLast()
    }
    
    /// Removes the given number of elements from the end of the array.
    ///
    /// - Parameter n: The number of elements to remove. `n` must be greater
    ///   than or equal to zero, and must be less than or equal to the number of
    ///   elements in the array.
    /// - Complexity: O(1).
    public mutating func removeLast(_ n: Int) {
        _elements.removeLast(n)
    }
    
    /// Removes all elements from the array.
    ///
    /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
    ///   the array after removing its elements. The default value is `false`.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = true) {
        _elements.removeAll(keepingCapacity: keepCapacity)
    }
    
    /// Removes an element from the array. If the array contains multiple
    /// instances of `element`, this method only removes the first one.
    ///
    /// - Complexity: O(_n_), where _n_ is the size of the array.
    public mutating func remove(_ element: Element) {
        guard let index = index(of: element) else { return }
        _elements.remove(at: index)
    }
}

// MARK: - More efficient variants of default implementations or implementations that need fewer constraints than the default implementations.
extension SortedArray {
    /// Returns the first index where the specified value appears in the collection.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func firstIndex(of element: Element) -> Index? {
        var range: Range<Index> = startIndex ..< endIndex
        var match: Index? = nil
        while case let .found(m) = search(for: element, in: range) {
            // We found a matching element
            // Check if its predecessor also matches
            if let predecessor = index(m, offsetBy: -1, limitedBy: range.lowerBound),
               compare(self[predecessor], element) == .orderedSame
            {
                // Predecessor matches => continue searching using binary search
                match = predecessor
                range = range.lowerBound ..< predecessor
            }
            else {
                // We're done
                match = m
                break
            }
        }
        return match
    }
    
    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Requires: The `predicate` must return `false` for elements of the array up to a given point, and `true` for
    ///   all elements after that point _(the opposite of `lastIndex(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 > … }` or `{ $0 >= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        var match: Index? = nil
        if case let .found(m) = try searchFirst(where: predicate) {
            match = m
        }
        return match
    }
    
    /// Returns the first element of the sequence that satisfies the given predicate.
    ///
    /// - Requires: The `predicate` must return `false` for elements of the array up to a given point, and `true` for
    ///   all elements after that point _(the opposite of `last(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 > … }` or `{ $0 >= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return self[index]
    }
    
    /// Returns the first index where the specified value appears in the collection.
    /// Old name for `firstIndex(of:)`.
    /// - Seealso: `firstIndex(of:)`
    public func index(of element: Element) -> Index? {
        return firstIndex(of: element)
    }
    
    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func contains(_ element: Element) -> Bool {
        return anyIndex(of: element) != nil
    }
    
    /// Returns the minimum element in the sequence.
    ///
    /// - Complexity: O(1).
    @warn_unqualified_access
    public func min() -> Element? {
        return first
    }
    
    /// Returns the maximum element in the sequence.
    ///
    /// - Complexity: O(1).
    @warn_unqualified_access
    public func max() -> Element? {
        return last
    }
}

// MARK: - APIs that go beyond what's in the stdlib
extension SortedArray {
    /// Returns an arbitrary index where the specified value appears in the collection.
    /// Like `index(of:)`, but without the guarantee to return the *first* index
    /// if the array contains duplicates of the searched element.
    ///
    /// Can be slightly faster than `index(of:)`.
    public func anyIndex(of element: Element) -> Index? {
        switch search(for: element) {
        case let .found(at: index): return index
        case .notFound(insertAt: _): return nil
        }
    }
    
    /// Returns the last index where the specified value appears in the collection.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func lastIndex(of element: Element) -> Index? {
        var range: Range<Index> = startIndex ..< endIndex
        var match: Index? = nil
        while case let .found(m) = search(for: element, in: range) {
            // We found a matching element
            // Check if its successor also matches
            let lastValidIndex = index(before: range.upperBound)
            if let successor = index(m, offsetBy: 1, limitedBy: lastValidIndex),
               compare(self[successor], element) == .orderedSame
            {
                // Successor matches => continue searching using binary search
                match = successor
                guard let afterSuccessor = index(successor, offsetBy: 1, limitedBy: lastValidIndex) else {
                    break
                }
                range =  afterSuccessor ..< range.upperBound
            }
            else {
                // We're done
                match = m
                break
            }
        }
        return match
    }
    
    /// Returns the index of the last element in the collection that matches the given predicate.
    ///
    /// - Requires: The `predicate` must return `true` for elements of the array up to a given point, and `false` for
    ///   all elements after that point _(the opposite of `firstIndex(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 < … }` or `{ $0 <= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        var match: Index? = nil
        if case let .found(m) = try searchLast(where: predicate) {
            match = m
        }
        return match
    }
    
    /// Returns the last element of the sequence that satisfies the given predicate.
    ///
    /// - Requires: The `predicate` must return `true` for elements of the array up to a given point, and `false` for
    ///   all elements after that point _(the opposite of `first(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 < … }` or `{ $0 <= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return self[index]
    }
}

// MARK: - Converting between a stdlib comparator function and Foundation.ComparisonResult
extension SortedArray {
    fileprivate func compare(_ lhs: Element, _ rhs: Element) -> Foundation.ComparisonResult {
        if areInIncreasingOrder(lhs, rhs) {
            return .orderedAscending
        } else if areInIncreasingOrder(rhs, lhs) {
            return .orderedDescending
        } else {
            // If neither element comes before the other, they _must_ be
            // equal, per the strict ordering requirement of `areInIncreasingOrder`.
            return .orderedSame
        }
    }
}

// MARK: - Binary search
extension SortedArray {
    /// The index where `newElement` should be inserted to preserve the array's sort order.
    fileprivate func insertionIndex(for newElement: Element) -> Index {
        switch search(for: newElement) {
        case let .found(at: index): return index
        case let .notFound(insertAt: index): return index
        }
    }
}

fileprivate enum Match<Index: Comparable> {
    case found(at: Index)
    case notFound(insertAt: Index)
}

extension Range where Bound == Int {
    var middle: Int? {
        guard !isEmpty else { return nil }
        return lowerBound + count / 2
    }
}

extension SortedArray {
    /// Searches the array for `element` using binary search.
    ///
    /// - Returns: If `element` is in the array, returns `.found(at: index)`
    ///   where `index` is the index of the element in the array.
    ///   If `element` is not in the array, returns `.notFound(insertAt: index)`
    ///   where `index` is the index where the element should be inserted to
    ///   preserve the sort order.
    ///   If the array contains multiple elements that are equal to `element`,
    ///   there is no guarantee which of these is found.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    fileprivate func search(for element: Element) -> Match<Index> {
        return search(for: element, in: startIndex ..< endIndex)
    }
    
    fileprivate func search(for element: Element, in range: Range<Index>) -> Match<Index> {
        guard let middle = range.middle else { return .notFound(insertAt: range.upperBound) }
        switch compare(element, self[middle]) {
        case .orderedDescending:
            return search(for: element, in: index(after: middle)..<range.upperBound)
        case .orderedAscending:
            return search(for: element, in: range.lowerBound..<middle)
        case .orderedSame:
            return .found(at: middle)
        }
    }
    
    /// Searches the array for the first element matching the `predicate` using binary search.
    ///
    /// - Requires: The `predicate` must return `false` for elements of the array up to a given point, and `true` for
    ///   all elements after that point _(the opposite of `searchLast(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 > … }` or `{ $0 >= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Parameter predicate: A closure that returns `false` for elements up to a point; and `true` for all after.
    /// - Returns: If `element` is in the array, returns `.found(at: index)`
    ///   where `index` is the index of the element in the array.
    ///   If `element` is not in the array, returns `.notFound(insertAt: index)`
    ///   where `index` is the index where the element should be inserted to
    ///   preserve the sort order.
    ///   If the array contains multiple elements that are equal to `element`,
    ///   there is no guarantee which of these is found.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    /// - SeeAlso: http://ruby-doc.org/core-2.6.3/Array.html#method-i-bsearch_index
    fileprivate func searchFirst(where predicate: (Element) throws -> Bool) rethrows -> Match<Index> {
        return try searchFirst(where: predicate, in: startIndex ..< endIndex)
    }
    
    fileprivate func searchFirst(where predicate: (Element) throws -> Bool, in range: Range<Index>) rethrows -> Match<Index> {
        guard let middle = range.middle else { return .notFound(insertAt: range.upperBound) }
        if try predicate(self[middle]) {
            if middle == 0 {
                return .found(at: middle)
            } else if !(try predicate(self[index(before: middle)])) {
                return .found(at: middle)
            } else {
                return try searchFirst(where: predicate, in: range.lowerBound ..< middle)
            }
        } else {
            return try searchFirst(where: predicate, in: index(after: middle) ..< range.upperBound)
        }
    }
    
    /// Searches the array for the last element matching the `predicate` using binary search.
    ///
    /// - Requires: The `predicate` must return `true` for elements of the array up to a given point, and `false` for
    ///   all elements after that point _(the opposite of `searchFirst(where:)`)_.
    ///   The given point may be before the first element or after the last element; i.e. it is valid to return `true`
    ///   for all elements or `false` for all elements.
    ///   For most use-cases, the `predicate` closure will use the form `{ $0 < … }` or `{ $0 <= … }` _(or equivalent,
    ///   if the SortedArray was initialized with a custom Comparator)_.
    ///
    /// - Parameter predicate: A closure that returns `false` for elements up to a point; and `true` for all after.
    /// - Returns: If `element` is in the array, returns `.found(at: index)`
    ///   where `index` is the index of the element in the array.
    ///   If `element` is not in the array, returns `.notFound(insertAt: index)`
    ///   where `index` is the index where the element should be inserted to
    ///   preserve the sort order.
    ///   If the array contains multiple elements that are equal to `element`,
    ///   there is no guarantee which of these is found.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    /// - SeeAlso: http://ruby-doc.org/core-2.6.3/Array.html#method-i-bsearch_index
    fileprivate func searchLast(where predicate: (Element) throws -> Bool) rethrows -> Match<Index> {
        return try searchLast(where: predicate, in: startIndex ..< endIndex)
    }
    
    fileprivate func searchLast(where predicate: (Element) throws -> Bool, in range: Range<Index>) rethrows -> Match<Index> {
        guard let middle = range.middle else { return .notFound(insertAt: range.upperBound) }
        if try predicate(self[middle]) {
            if middle == range.upperBound - 1 {
                return .found(at: middle)
            } else if !(try predicate(self[index(after: middle)])) {
                return .found(at: middle)
            } else {
                return try searchLast(where: predicate, in: index(after: middle) ..< range.upperBound)
            }
        } else {
            return try searchLast(where: predicate, in: range.lowerBound ..< middle)
        }
    }
}

#if swift(>=4.1)
extension SortedArray: Equatable where Element: Equatable {
    public static func == (lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool {
        // Ignore the comparator function for Equatable
        return lhs._elements == rhs._elements
    }
}
#else
public func ==<Element: Equatable> (lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool {
    return lhs._elements == rhs._elements
}

public func !=<Element: Equatable> (lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool {
    return lhs._elements != rhs._elements
}
#endif

#if swift(>=4.1.50)
extension SortedArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_elements)
    }
}
#endif
// https://github.com/semisagi0/kyopro-snippet/tree/main/snippets_swift
struct Deque<Element> {
    private var elements: [Element?]
    private var l: Int = 0
    private var r: Int = 0
    
    var count: Int {
        r - l
    }
    
    var capacity: Int {
        elements.count
    }
    
    var isEmpty: Bool {
        count == 0
    }
    
    init() {
        self.elements = [Element?](repeating: nil, count: 1)
    }
    
    private mutating func reallocate() {
        guard count == elements.count else { return }
        var newElements = [Element?](repeating: nil, count: elements.count * 2)
        for i in l ..< r {
            newElements[i - l] = elements[index(i)]
        }
        elements = newElements
        l = 0
        r = elements.count / 2
    }
    
    private mutating func index(_ k: Int) -> Int {
        var k = k % elements.count
        if k < 0 {
            k += elements.count
        }
        return k
    }
    
    private mutating func release(_ k: Int) -> Element {
        let k = index(k)
        let result = elements[k]!
        elements[k] = nil
        return result
    }
    
    mutating func pushFront(_ newElement: Element) {
        reallocate()
        l -= 1
        elements[index(l)] = newElement
    }
    
    mutating func pushBack(_ newElement: Element) {
        reallocate()
        elements[index(r)] = newElement
        r += 1
    }
    
    mutating func popFront() -> Element? {
        guard l < r else { return nil }
        defer { l += 1 }
        return release(l)
    }
    
    mutating func popBack() -> Element? {
        guard l < r else { return nil }
        r -= 1
        return release(r)
    }
}

struct Queue<Element> {
    private var deque = Deque<Element>()
    
    mutating func enqueue(_ newElement: Element) {
        deque.pushBack(newElement)
    }
    
    mutating func dequeue() -> Element? {
        deque.popFront()
    }
    
    func isEmpty() -> Bool {
        return deque.isEmpty
    }
}

struct PriorityQueue<T> {
    private var data: [T]
    private var ordered: (T, T) -> Bool
    
    public var isEmpty: Bool {
        return data.isEmpty
    }
    
    public var count: Int {
        return data.count
    }
    
    init(_ order: @escaping (T, T) -> Bool) {
        self.data = []
        self.ordered = order
    }
    
    init<Seq: Sequence>(_ seq: Seq, _ order: @escaping (T, T) -> Bool) where Seq.Element == T {
        self.data = []
        self.ordered = order
        
        for x in seq {
            push(x)
        }
    }
    
    public mutating func pop() -> T? {
        return data.popLast().map { item in
            var item = item
            if !isEmpty {
                swap(&item, &data[0])
                siftDown()
            }
            return item
        }
    }
    
    public mutating func push(_ item: T) {
        let oldLen = count
        data.append(item)
        siftUp(oldLen)
    }
    
    private mutating func siftDown() {
        var pos = 0
        let end = count
        
        data.withUnsafeMutableBufferPointer { bufferPointer in
            let _data = bufferPointer.baseAddress!
            swap(&_data[0], &_data[end])
            
            var child = 2 * pos + 1
            while child < end {
                let right = child + 1
                if right < end && ordered(_data[right], _data[child]) {
                    child = right
                }
                swap(&_data[pos], &_data[child])
                pos = child
                child = 2 * pos + 1
            }
        }
        siftUp(pos)
    }
    
    private mutating func siftUp(_ pos: Int) {
        var pos = pos
        while pos > 0 {
            let parent = (pos - 1) / 2;
            if ordered(data[parent], data[pos]) {
                break
            }
            data.swapAt(pos, parent)
            pos = parent
        }
    }
}

extension PriorityQueue: Sequence, IteratorProtocol {
    mutating func next() -> T? {
        return pop()
    }
}

import Foundation
func readInt() -> Int {
    return Int(readLine()!)!
}

func readInts() -> [Int] {
    return readLine()!.split(separator: " ").map { Int(String($0))! }
}

func readTwoStrings() -> (a: String, b: Int) {
    let array = readLine()!.split(separator: " ").map { $0 }
    return (a: String(array[0]), b: Int(array[1])!)
}

func readTwoInts() -> (a: Int, b: Int) {
    let ints = readLine()!.split(separator: " ").map { Int($0)! }
    return (a: ints[0], b: ints[1])
}


func readTwoFloats() -> (a: Float, b: Float) {
    let ints = readLine()!.split(separator: " ").map { Float($0)! }
    return (a: ints[0], b: ints[1])
}

func readThreeInts() -> (a: Int, b: Int, c: Int) {
    let ints = readLine()!.split(separator: " ").map { Int($0)! }
    return (a: ints[0], b: ints[1], c: ints[2])
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}
extension Character {
    var byte: UInt8 { utf8.first! }
}

func arc085_b() {
    let (N, Z, W) = readThreeInts()
    let A = readInts()
}

func abc085_d() {
    let (N, H) = readTwoInts()
    let AB = (0..<N).map { _ in readTwoInts() }
    let b = [Int](repeating: 0, count: 3001)
    var dp = [[Int]](repeating: b, count: 3001)
    var mx = -1
    var B: [Int] = []
    for ab in AB {
        mx = max(mx, ab.a)
        B.append(ab.b)
    }
    B.sort(by: >)
    var count = 0
    var sm = 0
    for b in B {
        if b > mx {
            count += 1
            sm += b
            if sm >= H {
                print(count)
                return
            }
        } else {
            break
        }
    }
    let remain = H-sm
    if remain % mx == 0 {
        print(count + (remain/mx))
    } else {
        print(count + Int((Double(remain)/Double(mx)).rounded(.up)))
    }
}
abc085_d()

func abc222_d() {
    let N = readInt()
    let A = readInts()
    let B = readInts()
    let b = [Int](repeating: 0, count: 3001)
    var dp = [[Int]](repeating: b, count: 3001)
    var before = 0
    var after = 0
    let MOD = 998244353
    for i in 0..<N {
        let a = A[i]
        let b = B[i]
        for k in a...b {
            if i - 1 >= 0 {
                dp[i][k] += (dp[i-1][min(k, after)]-dp[i-1][before-1])
                dp[i][k] %= MOD
            } else {
                dp[i][k] = 1
            }
        }
        before = a
        after = b
    }
    var ans = 0
    for d in dp[N-1] {
        ans += d
        ans %= MOD
    }
    print(ans)
}

func abc011_3() {
    let N = readInt()
    let NG = (0..<3).map { _ in readInt() }
    var dp: [Int] = [Int](repeating: 0, count: 301)
    dp[N] = 2
    for ng in NG {
       dp[ng] = 1
    }
    var count = 0
    var Next = Set<Int>()
    var Current = Set<Int>()
    Current.insert(N)
    while true {
        count += 1
        if Next.isEmpty == false {
            Current = Next
            Next = Set<Int>()
        }
        for i in Current.sorted() {
            if dp[i] == 1 { continue }
            if dp[i] == 0 { continue }
            if i - 1 >= 0 {
                if dp[i-1] == 2 { continue }
                if dp[i-1] != 1 { dp[i-1] = 2}
                Next.insert(i-1)
            }
            if i - 2 >= 0 {
                if dp[i-2] == 2 { continue }
                if dp[i-2] != 1 { dp[i-2] = 2}
                Next.insert(i-2)
            }
            if i - 3 >= 0 {
                if dp[i-3] == 2 { continue }
                if dp[i-3] != 1 { dp[i-3] = 2}
                Next.insert(i-3)
            }
        }
        if count == 100 { break }
    }
    if dp[0] == 2 { print("YES")
    } else {
        print("NO")
        
    }
}

func join20ho_d() {
    let (N, T, S) = readThreeInts()
    let AB = (0..<N).map { _ in readTwoInts() }
    let a = [Int](repeating: 0, count: T+1)
    var dp: [[Int]] = [[Int]](repeating: a, count:N+1)

    for i in 1...N {
        for j in (0...T).reversed() {
            dp[i][j] = dp[i-1][j]
            if j + AB[i-1].b <= T {
                if j < S && (j + AB[i-1].b > S) { continue }
                dp[i][j+AB[i-1].b] = max(dp[i-1][j] + AB[i-1].a, dp[i][j+AB[i-1].b])
                dp[i][j+AB[i-1].b] = max(dp[i-1][j] + AB[i-1].a, dp[i][j+AB[i-1].b])
            }
        }
    }
    print(dp[N].max()!)
}
import Combine

func join2012yo_d() {
    let (N, K) = readTwoInts()
    let AB = (0..<K).flatMap { _ -> (a: Int, b: Int) in readTwoInts() }.sorted { (lhs, rhs) -> Bool in
        lhs.a < rhs.a
    }
    let c = [Int](repeating: 0, count: 3)
    let b = [[Int]](repeating: c, count: 3)
    let a = [[[Int]]](repeating: b, count: 3)
    var dp: [[[[Int]]]] = [[[[Int]]]](repeating: a, count:N+1)
    var check: [Int] = [0, 0, 0]
    dp[0][0][0][0] = 1
    for i in 0..<N {
        for a in 0...2 {
            for b in 0...2 {
                for c in 0...2 {
                    if a == 2 && b == 2 && c == 2 { continue }
                    if a == 2 && b == 2 { continue }
                    if a == 2 && c == 2 { continue }
                    if b == 2 && c == 2 { continue }
                    for k in 0..<K {
                        if AB[k].a-1 == i {
                            if AB[k].b == 0 {
                                if a == 2 { continue }
                                dp[i+1][a+1][b][c] += dp[i][a][b][c]
                            }
                            
                            if AB[k].b == 1 {
                                if b == 2 { continue }
                                dp[i+1][a][b+1][c] += dp[i][a][b][c]
                            }
                            
                            if AB[k].b == 2 {
                                if c == 2 { continue }
                                dp[i+1][a][b][c+1] += dp[i][a][b][c]
                            }
                            continue
                        }
                    }

                    if a == 2 {
                        dp[i+1][a][b+1][c] += dp[i][a][b][c]
                        dp[i+1][a][b][c+1] += dp[i][a][b][c]
                        continue
                    }
                    if b == 2 {
                        dp[i+1][a+1][b][c] += dp[i][a][b][c]
                        dp[i+1][a][b][c+1] += dp[i][a][b][c]
                        continue
                    }
                    if c == 2 {
                        dp[i+1][a][b+1][c] += dp[i][a][b][c]
                        dp[i+1][a+1][b][c] += dp[i][a][b][c]
                        continue
                    }
                    dp[i+1][a+1][b][c] += dp[i][a][b][c]
                    dp[i+1][a][b+1][c] += dp[i][a][b][c]
                    dp[i+1][a][b][c+1] += dp[i][a][b][c]
                }
            }
        }
    }
    print(dp)
}
func abc189_d() {
    let N = readInt()
    let S = (0..<N).map { _ in readLine()! }
    let k = [Int](repeating: 0, count: 2)
    var dp: [[Int]] = [[Int]](repeating: k, count:N+1)
    dp[0][0] = 1
    dp[0][1] = 1
    for i in 0..<N {
        if S[i] == "AND" {
            dp[i+1][0] += dp[i][0] + 1
            dp[i+1][0] += dp[i][1] + 1
            dp[i+1][1] += dp[i][1] + 1
        } else {
            dp[i+1][0] += dp[i][0] + 1
            dp[i+1][1] += dp[i][0] + 1
            dp[i+1][1] += dp[i][1] + 1
        }
    }
    print(dp)
 }

func past201912_i() {
    let (N, M) = readTwoInts()
    let SC = (0..<M).flatMap { (m) -> (a: String, b: Int) in readTwoStrings() }.flatMap
    {
        (left, right) -> (a: String, b: Int) in
//            left.reduce("", combine: {(l: String, r: String) -> String in
//                let l = l == "Y" ? "1" : "0"
//                let r = r == "Y" ? "1" : "0"
//                return l + r
//            }), right)
        var l = ""
        for s in left {
            l += (s == "Y" ? "1" : "0")
        }
        return (l, right)
    }
    let k = [Int](repeating: Int.max, count: 1<<N)
    var dp: [[Int]] = [[Int]](repeating: k, count:M+1)
    dp[0][0] = 0

    for m in 0..<M {
        dp[m+1] = dp[m]
        for v in 0..<N {
                guard dp[m][1<<v] != Int.max else { continue }
                let left: Int = dp[m][v]+SC[m].b
                let right: Int = dp[m+1][Int(SC[m].a, radix: 2)! | 1<<v]
                dp[m+1][Int(SC[m].a, radix: 2)! | 1<<v] = min(left, right)
        }
    }
    
    print(dp.flatMap { $0 }.last! == Int.max ? -1 : dp.flatMap { $0 }.last!)
}
func abc211_a() {
    let (N, M) = readTwoFloats()
    let C = CurrentValueSubject<(N: Float, M: Float), Never>((N, M))
    var cancellables: Set<AnyCancellable> = []
    // Subscribe
    Just((N, M))
        .sink(receiveValue: { (N, M) in
            print((N-M)/3 + M)
        }).store(in: &cancellables)
}
//abc211_a()
func joi2015yo_d() {
    let (N, M) = readTwoInts()
    let distance = (0..<N).map { _ in readInt() }
    let weather = [0] + (0..<M).map { _ in readInt() }
    let k = [Int](repeating: Int.max, count: N+1)
    var dp: [[Int]] = [[Int]](repeating: k, count:M+1)
    for day in 0...M {
        dp[day][0] = 0
    }
    for day in (1...M) {
        for k in (1...N) {
            if dp[day-1][k] != Int.max {
                dp[day][k] = dp[day-1][k]
            }
            if dp[day-1][k-1] != Int.max {
                dp[day][k] = min(dp[day-1][k-1] + (distance[k-1] * weather[day]), dp[day][k])
            }
        }
    }
    print(dp.flatMap{$0}.filter{ $0 != Int.max }.last!)
}
//joi2015yo_d()

func joi2013yo_d() {
    let (D, N) = readTwoInts()
    var T: [Int]  = []
    for _ in 0..<D {
        let t = readInt()
        T.append(t)
    }
    var ABC: [(a: Int, b: Int, c: Int)] = []
    let x = [Int](repeating: -1, count: N+1)
    var dp: [[Int]] = [[Int]](repeating: x, count: D+1)
    for _ in 0..<N {
        let (a, b, c) = readThreeInts()
        ABC.append((a, b, c))
    }
    for i in 0..<N {
        let temp = T[0]
        if ABC[i].a <= temp && temp <= ABC[i].b {
            dp[0][i] = 0
        }
    }
    for i in 1..<D {
        let temp = T[i]
        for j in (0..<N) {
            if ABC[j].a <= temp && temp <= ABC[j].b {
                for k in (0..<N) {
                    if dp[i-1][k] != -1 {
                        dp[i][j] = max(dp[i][j], dp[i-1][k] + abs(ABC[j].c - ABC[k].c))
                    }
                }
            }
        }
    }
    print(dp[D-1].max()!)
    
}

func wupc2021_4() {
    let N = readInt()
    let x = [Int](repeating: Int.min, count: N+1)
    var dp: [[Int]] = [[Int]](repeating: x, count: N+1)
    var YX: [[Int]] = [[Int]]()
    for _ in 0..<N {
        let P = readInts()
        YX.append(P)
    }
    dp[0][0] = YX[0][0]
    for i in 1..<N {
        for j in 0..<i+1 {
            if i - 1 >= 0 && j - 1 >= 0 {
                dp[i][j] = max(dp[i-1][j-1] + YX[i][j], dp[i][j])
            }
            if i - 1 >= 0 {
                dp[i][j] = max(dp[i-1][j] + YX[i][j], dp[i][j])
            }
        }
    }
    print(dp[N-1].max()!)
}

func a2011yo_d() {
    let N = readInt()
    let P = readInts()
    let x = [Int](repeating: 0, count: 21)
    var dp: [[Int]] = [[Int]](repeating: x, count: N+1)
    dp[0][0] = 1
    dp[1][P[0]] = 1
    for i in 1..<N-1 {
        for j in 0..<21 {
            if j + P[i] <= 20 {
                dp[i+1][j+P[i]] += dp[i][j]
            }
            if j - P[i] >= 0 {
                dp[i+1][j-P[i]] += dp[i][j]
            }
        }
    }
    print(dp[N-1][P.last!])
}

func tdpcA() {
    let (N, A) = readTwoInts()
    let P = readInts()
    let e = [Int](repeating: 0, count: 2501)
    let x = [[Int]](repeating: e, count: 51)
    var dp: [[[Int]]] = [[[Int]]](repeating: x, count: N+1)
    dp[0][0][0] = 1
    for i in 0..<N {
        for j in (0..<50) {
            for k in (0..<2501) {
                dp[i+1][j][k] += dp[i][j][k]
                dp[i+1][j+1][k+P[i]] += dp[i][j][k]
            }
        }
    }
    var ans = 0
    for j in 1...50 {
        for k in (0...2500) {
            if k % j == 0 && k / j == A {
                ans += dp[N][j][k]
            }
        }
    }
    print(ans)
}

func abc054_d() {
    let (N, M1, M2) = readThreeInts()
    var ans: [(m1: Int, m2: Int)] = []
    var count = 1
    var ABC: [(a: Int, b: Int, c: Int)] = []
    for _ in 0..<N {
        let (a, b, c) = readThreeInts()
        ABC.append((a, b, c))
    }
    let A = ABC.map { $0.a }.reduce(0, +)
    let B = ABC.map { $0.b }.reduce(0, +)
    while true {
        let m1 = count * M1
        let m2 = count * M2
        if m1 > A || m2 > B {
            break
        }
        ans.append((m1, m2))
        count += 1
    }
    
    let y = [Int](repeating: Int.max, count: 401)
    let XY: [[Int]] = [[Int]](repeating: y, count: 401)
    var res = Int.max
    var dp: [[[Int]]] = [[[Int]]](repeating: XY, count: N + 1)
    dp[0][0][0] = 0
    for i in 0 ..< N {
        let (a, b, c) = ABC[i]
        for x in (0 ... 400) {
            for y in (0 ... 400) {
                guard dp[i][x][y] != Int.max else {
                    continue
                }
                if x + a > 400 || y + b > 400 { continue }
                // 加えない処理
                dp[i + 1][x][y] = min(dp[i + 1][x][y], dp[i][x][y])
                
                // 加える処理
                dp[i + 1][x+a][y+b] = min(dp[i + 1][x+a][y+b], dp[i][x][y] + c)
            }
        }
    }
    for (m1, m2) in ans {
        res = min(res, dp[N][m1][m2])
    }
    if res == Int.max {
        print(-1)
        return
    }
    print(res)
}


//func tenka1() {
//    let N = readInt()
//    let S = readLine()!.map { $0.byte }
//    let T = (0..<N).map { _ in readLine()!.map { $0.byte }}
//    var dp = [Int](repeating: 0, count: S.count+1)
//    dp[0] = 1
//
//    let MOD = 1000000007
//    for i in 0..<S.count {
//        for t in T where i + t.count <= S.count {
//            if S[i+t.count] == t {
//                dp[i+t.count] += dp[i]
//                dp[i+t.count] %= MOD
//            }
//        }
//    }
//    print(dp.last!)
//}
//tenka1()

func arc006_3() {
    let N = readInt()
    var W: [Int] = []
    for _ in 0 ..< N {
        let w = readInt()
        W.append(w)
    }
    let e: [Int] = []
    var dp = [[Int]](repeating: e, count: N+1)
    var count = 0
    dp[0].append(W[0])
    count += 1
    for w in 1 ..< W.count {
        var mn = Int.max
        var idx = -1
        for d in 0 ..< dp.count {
            if dp[d].isEmpty { break }
            let last = dp[d].last!
            if last < W[w] { continue }
            if last - W[w] < mn {
                mn = min(mn, last - W[w])
                idx = d
            }
        }
        if idx == -1 {
            dp[count].append(W[w])
            count += 1
            continue
        }
        dp[idx].append(W[w])
    }
    print(dp.filter { !$0.isEmpty }.count)
}

func abc179_d() {
    let (N, K) = readTwoInts()
    var LR: [(l: Int, r: Int)] = []
    var st = Set<Int>()
    for _ in 0 ..< K {
        let (l, r) = readTwoInts()
        for i in l ... r {
            st.insert(i)
        }
        LR.append((l, r))
    }
    var dp = [Int](repeating: 0, count: N+1)
    dp[0] = 1
    dp[1] = 1
    let MOD = 998244353
    let l = st.sorted()
    for i in 1 ... N {
        for j in l {
            if i + j <= N {
                dp[i+j] += dp[i]
                dp[i+j] %= MOD
            }
        }
    }
    print(dp[N])
}
func dp_a() {
    let N = readInt()
    let H = readInts()
    var dp = [Int](repeating: 0, count: N+1)
    for i in 0 ... N {
        if i + 1 < N && i - 1 >= 0 {
            dp[i+1] = min(dp[i] + abs(H[i] - H[i+1]), dp[i-1] + abs(H[i-1] - H[i+1]))
        }
        
        if i + 2 < N {
            dp[i+2] = min(dp[i] + abs(H[i] - H[i+2]), dp[i+1] + abs(H[i+1] - H[i+2]))
        }
    }
    print(dp)
    print(dp[N])
}

func dp_c() {
    let N = readInt()
    var ABC: [(a: Int, b: Int, c: Int)] = []
    let e = [Int](repeating: 0, count: 3)
    var dp: [[Int]] = [[Int]](repeating: e, count: N+1)
    for _ in 0 ..< N {
        let (a, b, c) = readThreeInts()
        ABC.append((a, b, c))
    }
    for i in 0 ..< N {
        let a = ABC[i].a
        let b = ABC[i].b
        let c = ABC[i].c
        dp[i+1][0] += max(dp[i][1] + a, dp[i][2] + a)
        dp[i+1][1] += max(dp[i][0] + b, dp[i][2] + b)
        dp[i+1][2] += max(dp[i][0] + c, dp[i][1] + c)
    }
    print(max(dp[N][0], dp[N][1], dp[N][2]))
}

func abc032_d() {
    let (N, W) = readTwoInts()
    var VW: [(weight: Int, value: Int)] = []
    var dp = [Int](repeating: 0, count: W+1)
    for _ in 0 ..< N {
        let (w, v) = readTwoInts()
        VW.append((w, v))
    }
    for i in 0 ..< N {
        for w in (0 ... W).reversed() {
            let value = VW[i].value
            let weight = VW[i].weight
            if w + weight <= W {
                dp[w+weight] = max(dp[w] + value, dp[w+weight])
            }
        }
    }
    print(dp[W])
}

func abc220_d() {
    let N = readInt()
    let A = readInts()
    let MOD = 998244353
    let e = [Int](repeating: 0, count: 10)
    var dp: [[Int]] = [[Int]](repeating: e, count: N)
    dp[0][A[0]] = 1
    for i in 0 ..< N-1 {
        for k in 0 ..< 10 {
            dp[i+1][(k+A[i+1])%10] += dp[i][k]
            dp[i+1][(k+A[i+1])%10] %= MOD
            dp[i+1][(k*A[i+1])%10] += dp[i][k]
            dp[i+1][(k*A[i+1])%10] %= MOD
        }
    }
    for d in dp[N-1] {
        print(d)
    }
}

func arc067_b() {
    let (N, A, B) = readThreeInts()
    let X = readInts()
    var ans = 0
    for i in 1  ..< N {
        let diff = X[i] - X[i-1]
        let a = A*diff
        ans += min(a, B)
    }
    print(ans)
}


func abc219_d() {
    let N = readInt()
    let (X, Y) = readTwoInts()
    let y = [Int](repeating: Int.max, count: Y + 1)
    let XY: [[Int]] = [[Int]](repeating: y, count: X + 1)
    var dp: [[[Int]]] = [[[Int]]](repeating: XY, count: N + 1)
    dp[0][0][0] = 0
    for i in 0 ..< N {
        let (a, b) = readTwoInts()
        for x in 0 ... X {
            for y in 0 ... Y {
                guard dp[i][x][y] != Int.max else {
                    continue
                }
                let xMAX = min(x + a, X)
                let yMAX = min(y + b, Y)
                dp[i + 1][x][y] = min(dp[i + 1][x][y], dp[i][x][y])
                dp[i + 1][xMAX][yMAX] = min(dp[i + 1][xMAX][yMAX], dp[i][x][y] + 1)
            }
        }
    }
    let ans = dp[N][X][Y]
    if ans == Int.max {
        print(-1)
        return
    }
    print(ans)
}


func abc217_e() {
    let Q = readInt()
    var queue = Queue<Int>()
    var priorityQueue = PriorityQueue<Int>([], <=)
    for _ in 0..<Q {
        let q = readInts()
        switch q.first {
        case 1:
            queue.enqueue(q.last!)
        case 2:
            if !priorityQueue.isEmpty {
                print(priorityQueue.pop()!)
            } else {
                print(queue.dequeue()!)
            }
        default:
            while !queue.isEmpty() {
                priorityQueue.push(queue.dequeue()!)
            }
        }
    }
}

func abc134_d() {
    let N = readInt()
    var A = readInts().sorted()
    var ans = Set<String>()
    for i in stride(from: N - 1, to: 0, by: -1) {
        for j in stride(from: i + 1, to: N, by: i + 1) {
            if ans.contains(String(j)) {
                A[i] += 1
            }
        }
        if A[i] % 2 == 1 {
            ans.insert(String(i + 1))
        }
    }
    print(ans.count)
    print(ans.joined(separator: " "))
}

func abc147_d() {
    let N = readInt()
    let A = readInts()
    let MOD = Int(1e9) + 7
    var ans = 0
    for i in 0..<61 {
        let mask = (1 << i) % MOD
        var one = 0
        var zero = 0
        for a in A {
            if (a & (1 << i)) == 1 {
                one += 1
            } else {
                zero += 1
            }
        }
        ans += (mask*one*zero)
        ans %= MOD
    }
    print(ans%MOD)
}

func abc170_d() {
    let N = readInt()
    let A = readInts().sorted()

    var dp: [Bool] = .init(repeating: true, count: A.max()! + 1)
    for n in 0..<A.count {
        let a = A[n]
        if n > 0 && a == A[n-1] {
            dp[a] = false
            continue
        }
        var j = a * 2
        while j <= A.last! {
            dp[j] = false
            j += a
            
        }
    }
    print(dp)
    print(dp.filter { $0 }.count )
}

func abc217_d() {
    let (L, Q) = readTwoInts()
    var sortedArray = SortedArray(unsorted: [0, L], areInIncreasingOrder: <)
    for _ in 0..<Q {
        let (c, x) = readTwoInts()
        if c == 1 {
            sortedArray.insert(x)
        } else {
            let idx = sortedArray.firstIndex(where: { $0 >= x})!
            print(sortedArray[idx] - sortedArray[idx-1])
        }
    }
}

func abc080_b() {
    let N = readLine()!
    let sum = N.map { Int(String($0))! }.reduce(0, +)
    print(Int(N)! % sum == 0 ? "Yes" : "No")
}

func abc212_e() {
    let (N, M, K) = readThreeInts()
    var paths: [(x: Int, y: Int)] = []
    for _ in 0..<M {
        var (x, y) = readTwoInts()
        x -= 1
        y -= 1
        paths.append((x, y))
    }
    
    let e = [Int](repeating: 0, count: N)
    var dp: [[Int]] = [[Int]](repeating: e, count: K + 1)
    dp[0][0] = 1
    for day in 0..<K {
        let sum = dp[day].reduce(0, +)
        for path in 0..<N {
            dp[day+1][path] = sum - dp[day][path]
        }
        
        paths.forEach { from, to in
            dp[day+1][from] -= dp[day][to]
            dp[day+1][to] -= dp[day][from]
        }
        
        for path in 0..<N {
            dp[day+1][path] %= 998244353
        }
    }
    print(dp[K][0])
}

func abc162_d() {
    let N = readInt()
    let S = Array(readLine()!)
    var r = 0
    var g = 0
    var b = 0
    for s in S {
        if s == "R" {
            r += 1
        }
        if s == "G" {
            g += 1
        }
        
        if s == "B" {
            b += 1
        }
    }
    var ans = r*g*b
    for i in 0..<N-2 {
        for j in i+1..<N-1 {
            let k = j + (j-i)
            if k >= N {
                break
            }
            if S[i] != S[j] && S[i] != S[k] && S[j] != S[k] {
                ans -= 1
            }
        }
    }
    print(ans)
}


//abc080_b()

func abc078_b() {
    let input = readInts()
    var X = input[0]
    let Y = input[1]
    let Z = input[2]
    var ans = 0
    X -= Y+Z*2
    ans += 1
    ans += X/(Y+Z)
    
    print(ans)
}

func abc085_b() {
    let N = readInt()
    var l: [Int] = []
    for _ in 0..<N {
        let d = readInt()
        l.append(d)
    }
    print(l.reduce([], { $0.contains($1) ? $0 : $0 + [$1] }).count)
}

func isSquare(n: Double) -> Bool {
    let sqrt = floor(n.squareRoot())
    return sqrt * sqrt == n
}

func abc077_b() {
    let N = readInt()
    for n in (1...N).reversed() {
        if isSquare(n: Double(n)) {
            print(n)
            return
        }
    }
}

func abc020_b () {
    let inputs = readInts()
    print(Int(String(inputs[0]) + String(inputs[1]))! * 2)
}

func abc073_b () {
    var ans = 0
    let N = readInt()
    for _ in 0..<N {
        let inputs = readInts()
        ans += inputs[1] - inputs[0] + 1
    }
    print(ans)
}

func abc026_b () {
    var evens: [Int] = []
    var odds: [Int] = []
    var all: [Int] = []
    let N = readInt()
    for _ in 0..<N {
        let R = readInt()
        all.append(R)
    }

    for (i, e) in all.sorted(by: >).enumerated() {
        if i % 2 == 0 {
            evens.append(e)
        } else {
            odds.append(e)
        }
    }
    let ans = evens.map { $0 * $0 }.reduce(0, +) - odds.map { $0 * $0 }.reduce(0, +)
    print(Double(ans) * Double.pi)
}

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased()  + self.lowercased().dropFirst()
    }
}

func abc012_b () {
    print(readLine()!.firstUppercased)

}

func abc007_b () {
    print(readLine()! == "a" ? -1 : "a")
}

func abc028_b () {
    let S = readLine()!
    let A = String(S.filter { $0 == "A" }.count)
    let B = String(S.filter { $0 == "B" }.count)
    let C = String(S.filter { $0 == "C" }.count)
    let D = String(S.filter { $0 == "D" }.count)
    let E = String(S.filter { $0 == "E" }.count)
    let F = String(S.filter { $0 == "F" }.count)
    print(A + " " + B + " " + C + " " + D + " " + E + " " + F)
}

func abc097_b () {
    let x = Double(Int(readLine()!)!)
    var ans: Double = 1
    for b in 2..<32 {
        var p: Double = 2
        while pow(Double(b), p) <= x {
            ans = max(ans, pow(Double(b), p))
            p += 1
        }
    }
    print(Int(ans))
}

func abc093_b () {
    var ans: [Int] = []
    let inputs = readInts()
    for x in inputs[0]..<inputs[0]+inputs[2] {
        ans.append(x)
    }
    
    for x in inputs[1]-inputs[2]+1...inputs[1] {
        if !ans.contains(x) {
            ans.append(x)
        }
    }
    ans.filter { $0 >= inputs[0] && $0 <= inputs[1] }.forEach { print($0) }
        

}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

func abc071_b () {
    let S = readLine()!
    let T = readLine()!
    if S == T {
        print("Yes")
        return
    }
    
    var ans = 0
    var count: Int
    for i in 1..<T.count {
        count = 0
        for k in i..<T.count {
            if S[k] == T[k] {
                count += 1
            }
        }
        print(count)
        
        for k in (0..<i).reversed() {
            print(S[T.count-1-k])
            if S[T.count-1-k] == T[k] {
                count += 1
            }
                print(count)
        }
        ans = max(ans, count)
    }
    
    if ans == T.count {
        print("Yes")
    } else {
        print("No")
    }
    

}


func abc094_b () {
    let inputs = readInts()
    let A = readInts()
    var ans = 1000007
    var count = 0
    for i in inputs[2]...inputs[0] {
        if A.contains(i) {
            count += 1
        }
    }
    ans = min(count, ans)
    count = 0
    for i in 0...inputs[2] {
        if A.contains(i) {
            count += 1
        }
    }
    ans = min(count, ans)
    print(ans)
}

func tenka1_2019_a() {
    let inputs = readInts()
    
    if inputs[0] < inputs[2] && inputs[2] < inputs[1] && inputs[0] < inputs[1] {
        print("Yes")
        return
    }
    
    if inputs[0] > inputs[2] && inputs[2] > inputs[1] && inputs[0] > inputs[1] {
        print("Yes")
        return
    }
    print("No")
}

enum NumError: Error {
    case invalid(String)
}

extension NumError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalid(let errorMessage):
            return errorMessage
        }
    }
}

func caddi2018b_aa() throws -> Int {
    let N = readInt()
    
    if N < 999 {
        throw NumError.invalid("1000から9999の値を入れてください")
    }
    
    if N >= 10000 {
        throw NumError.invalid("1000から9999の値を入れてください")
    }
    
    return String(N).map {$0}.filter {$0 == "2"}.count
}

func caddi2018b_a() -> Result<Int, NumError> {
    let N = readInt()
    
    if N < 999 {
        return .failure(.invalid("1000から9999の値を入れてください"))
    }
    
    if N >= 10000 {
        return .failure(.invalid("1000から9999の値を入れてください"))
    }
    
    return .success(String(N).map {$0}.filter {$0 == "2"}.count)
}

func tenka1_2018_a() {
    let S = readLine()!
    var reversedString = ""
    for char in S {
        reversedString = "\(char)" + reversedString
    }
    print(reversedString)
}

func tenka1_2017_a() {
    let S = readLine()!
    print(S.map { $0 }.filter { $0 == "1"}.count)
}

func abc178_c() {
    let N = readInt()
    let mod = 1000000007
    var w = 1
    var n = 1
    var e = 1
    for _ in 1...N {
        w *= 10
        w %= mod
        
        n *= 9
        n %= mod
        
        e *= 8
        e %= mod
        
    }
    let result = (w - e - ((n - e) * 2)) % mod
    if result >= 0 {
        print(result)
    } else {
        print(mod + result)
    }
}

func soundhound2018_a() {
    let inputs = readInts()
    if inputs[0] + inputs[1] == 15 {
        print("+")
        return
    }
    if inputs[0] * inputs[1] == 15 {
        print("*")
        return
    }
    print("x")
}

func soundhound2018_b() {
    guard let S = readLine() else {
        return
    }
    let w = readInt()
    
    var ans = S[0]
    for i in w..<S.count {
        if i % w == 0 {
            ans += S[i]
        }
    }
    print(ans)
}

func abc009_2() {
    let N = readInt()
    var As: [Int] = []
    for _ in 0..<N {
        let A = readInt()
        if As.contains(A) {
            continue
        }
        As.append(A)
    }
    print(As.sorted()[As.count-2])
}

extension String {
    mutating func swapAt(_ index1: Int, _ index2: Int) {
        var characters = Array(self)
        characters.swapAt(index1, index2)
        self = String(characters)
    }
}

func abc018_2() {
    var S = readLine()!
    let N = readInt()
    for _ in 0..<N {
        let input = readInts()
        var pre = S.prefix(input[0]-1)
        var middle = S[S.index(S.startIndex, offsetBy: input[0]-1)..<S.index(S.startIndex, offsetBy: input[1])]
        var end = S.suffix(S.count - input[1])
        S = pre + String(middle.reversed()) + end
    }
    print(S)
}

func tenka1_2018_b() {
    let input = readInts()
    var t = input[0]
    var a = input[1]
    let k = input[2]
    
    if t % 2 != 0 {
        t -= 1
        t /= 2
        a += t
    } else {
        t /= 2
        a += t
    }
    
    if k == 1 {
        print(t, a)
        return
    } else if k == 2 {
        if a % 2 != 0 {
            a -= 1
            a /= 2
            t += a
        } else {
            a /= 2
            t += a
        }
        print(t, a)
        return
    } else {
        if a % 2 != 0 {
            a -= 1
            a /= 2
            t += a
        } else {
            a /= 2
            t += a
        }
        for i in 3...input[2] {
            if i % 2 != 0 {
                if t % 2 != 0 {
                    t -= 1
                    t /= 2
                    a += t
                } else {
                    t /= 2
                    a += t
                }
            } else {
                if a % 2 != 0 {
                    a -= 1
                    a /= 2
                    t += a
                } else {
                    a /= 2
                    t += a
                }
            }
        }
    }
    print(t, a)
}


func tenka1_2019_b() {
    let N = readInt()
    let S = readLine()!
    let K = readInt()
    let target = S[K-1]
    var ans = ""
    for i in 0..<N {
        if S[i] == target {
            ans += target
        } else {
            ans += "*"
        }
    }
    print(ans)
}

func formula_2014_qualA_a() {
    let N = readInt()
    var a = 1
    while a*a*a <= N {
        if a*a*a == N {
            print("YES")
            return
        }
        a += 1
    }
    print("NO")
}

func code_festival_2015_qualA_a() {
    var S = readLine()!
    S = String(S.dropLast())
    S.append("5")
    print(S)
}

func hhkb2020_a() {
    var S = readLine()!
    var T = readLine()!
    
    if S == "Y" {
        print(T.uppercased())
    } else {
        print(T)
    }
}

func pakencamp_2019_day3_a() {
    let input = readInts()
    print(input[1]-input[0]+1)
}

func nikkei2019ex_a() {
    let S = readLine()!
    for i in 0..<S.count {
        print(i + 1)
    }
}

func iroha2019_day1_a() {
    print(readLine()![0])
}

func hitachi2020_a() {
    let S = readLine()!
    var flag1 = false
    var flag2 = false
    var count = 0
    if S.count % 2 != 0 {
        print("No")
        return
    }
    for (index, char) in S.enumerated() {
        if count == 2 {
            if flag1 && flag2 {
                count = 0
            } else {
                print("No")
                return
            }
        }
        
        if index % 2 == 0 {
            if char == "h" {
                flag1 = true
            } else {
                print("No")
                return
            }
        } else {
            if char == "i" {
                flag2 = true
            } else {
                print("No")
                return
            }
        }
        count += 1
    }
    
    print("Yes")
}

func m_solutions2019_a() {
    let N = readInt()
    print(180*(N-2))
    
}
func diverta2019_a() {
    let input = readInts()
    print(input[0] - input[1] + 1)
}

func diverta2019_2a() {
    let input = readInts()
    if input[1] == 1 {
        print(0)
        return
    }
    let amari = input[0] - input[1]
    print(amari)
}

func isPalindrome(str: String) -> Bool {
    let rev = String(str.reversed())
    
    if str == rev {
        return true
    } else {
        return false
    }
}

func arc031_1() {
//    let S = readLine()!
//    if isPalindrome(str: S) {
//        print("YES")
//    } else {
//        print("NO")
//    }
    for i in 0..<10 {
        if i == 5 {
            print("hello")
            return
        }
        print(i)
    }
    
    print("aaaaaaaaaaaaaaaa")

}

func past201912_b() {
    let N = readInt()
    var temp = 0
    for n in 0..<N {
        let A = readInt()
        if n == 0 {
            temp = A
            continue

        } else {
            
        }
        if A == temp {
            print("stay")
        } else if A < temp {
            let d = temp - A
            print("down " + String(d))
        } else {
            let d = A - temp
            print("up " + String(d))
        }
        temp = A
    }
}

func abc184_b() {
    let array = [-10, -2, -1, -4, -200000, 0]
    var sortedArray = array.sorted() {
        $0 < $1
    }
    let len = sortedArray.count
    let right = sortedArray[len-1] * sortedArray[len-2] * sortedArray[len-3]
    let left = sortedArray[0] * sortedArray[1] * sortedArray[len-1]
    print(max(left, right))
}
//abc184_b()

//do {
//    try print(caddi2018b_a())
//} catch NumError.invalid(let errorMessage) {
//    print(errorMessage)
//}
