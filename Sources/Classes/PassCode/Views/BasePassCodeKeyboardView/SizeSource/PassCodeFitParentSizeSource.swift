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

public final class PassCodeFitParentSizeSource: SizeSource<PassCodeButtonItem> {

    public let lineSpacing: CGFloat
    public let interitemSpacing: CGFloat

    private let itemsInRow: CGFloat
    private let rowsInColumn: CGFloat

    public init(lineSpacing: CGFloat,
                interitemSpacing: CGFloat,
                itemsInRow: UInt = 3,
                rowsInColumn: UInt = 4) {

        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.itemsInRow = CGFloat(itemsInRow)
        self.rowsInColumn = CGFloat(rowsInColumn)
    }

    public override func size(at index: Int,
                              data: PassCodeButtonItem,
                              collectionSize: CGSize) -> CGSize {

        let interitemHorizontalSpacings = interitemSpacing * itemsInRow

        let itemWidth = (collectionSize.width - interitemHorizontalSpacings) / itemsInRow

        let interitemVerticalSpacings = lineSpacing * rowsInColumn
        let itemHeight = (collectionSize.height - interitemVerticalSpacings) / rowsInColumn

        let itemDimesion = min(itemWidth, itemHeight)

        let itemsInRowWithItemDimension = collectionSize.width / (itemDimesion + interitemSpacing)
        let rowsInColumnWithItemDimension = collectionSize.height / (itemDimesion + lineSpacing)

        if itemsInRowWithItemDimension > itemsInRow {
            // number of items in row limit exceeded
            // return initially calculated itemWidth, breaking height limit
            return CGSize(width: itemWidth, height: itemWidth)
        } else if rowsInColumnWithItemDimension > rowsInColumn {
            // number of rows in column limit exceeded
            // return initially calculated itemHeight, breaking width limit
            return CGSize(width: itemHeight, height: itemHeight)
        }

        return CGSize(width: itemDimesion, height: itemDimesion)
    }
}
