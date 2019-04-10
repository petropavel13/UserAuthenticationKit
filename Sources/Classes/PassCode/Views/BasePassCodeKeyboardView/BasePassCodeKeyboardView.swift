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

open class BasePassCodeKeyboardView: CollectionView, UIGestureRecognizerDelegate {

    public override init(frame: CGRect) {
        super.init(frame: frame)

        bindTapGestureRecognizer()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        bindTapGestureRecognizer()
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {

        guard let itemProvider = provider as? ItemProvider,
            touch.view is UIControl,
            gestureRecognizer is UITapGestureRecognizer else {

                return true
        }

        for (cell, index) in zip(visibleCells, visibleIndexes).reversed() {
            let locationInCell = convert(touch.location(in: self), to: cell)

            if cell.point(inside: locationInCell, with: nil) {
                itemProvider.didTap(view: cell, at: index)
                break
            }
        }

        return false
    }
}

private extension BasePassCodeKeyboardView {
    func bindTapGestureRecognizer() {
        gestureRecognizers?
            .compactMap { $0 as? UITapGestureRecognizer }
            .forEach { $0.delegate = self }
    }
}
