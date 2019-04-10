//
//  Copyright (c) 2018 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the Software), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CollectionKit

public final class PassCodeDataSource: ArrayDataSource<PassCodeButtonItem> {

    public var leadingBottomItem: PassCodeButtonItem? {
        didSet {
            if let newLeadingItem = leadingBottomItem {
                if oldValue != nil {
                    data[.leadingButtonItemIndex] = newLeadingItem
                } else {
                    data.insert(newLeadingItem, at: .leadingButtonItemIndex)
                }
            } else {
                data.remove(at: .leadingButtonItemIndex)
            }
        }
    }

    public var trailingBottomItem: PassCodeButtonItem? {
        didSet {
            if let newTrailingItem = trailingBottomItem {
                if oldValue != nil {
                    data[data.endIndex - 1] = newTrailingItem
                } else {
                    data.append(newTrailingItem)
                }
            } else {
                data.removeLast()
            }
        }
    }

    public init(leadingBottomItem: PassCodeButtonItem? = nil,
                trailingBottomItem: PassCodeButtonItem? = nil) {

        self.leadingBottomItem = leadingBottomItem
        self.trailingBottomItem = trailingBottomItem

        let lastRowItems: [PassCodeButtonItem?] = [leadingBottomItem, .digit(0), trailingBottomItem]

        super.init(data: .oneToNineDigits + lastRowItems.compactMap { $0 })
    }
}

public extension PassCodeDataSource {

    func update(leadingBottomItem: PassCodeButtonItem?, trailingBottomItem: PassCodeButtonItem?) {
        let hasTrailingItem = self.leadingBottomItem != nil
        let hasLeadingItem = self.trailingBottomItem != nil

        let removeLeadingItem = leadingBottomItem == nil && hasLeadingItem
        let removeTrailingItem = trailingBottomItem == nil && hasTrailingItem

        var dataCopy = data

        if removeTrailingItem {
            dataCopy.removeLast()
        }

        if removeLeadingItem {
            dataCopy.remove(at: .leadingButtonItemIndex)
        }

        if let newLeadingItem = leadingBottomItem {
            dataCopy.insert(newLeadingItem, at: .leadingButtonItemIndex)
        }

        if let newTrailingItem = trailingBottomItem {
            dataCopy.append(newTrailingItem)
        }

        data = dataCopy
    }
}

private extension Int {

    static let numberOfRows = 4
    static let numberOfItemsInRow = 3
    static let leadingButtonItemIndex = .numberOfItemsInRow * (.numberOfRows - 1)
}

private extension Array where Element == PassCodeButtonItem {

    static var oneToNineDigits: [Element] {
        return [
            .digit(1),
            .digit(2),
            .digit(3),
            .digit(4),
            .digit(5),
            .digit(6),
            .digit(7),
            .digit(8),
            .digit(9)
        ]
    }
}
