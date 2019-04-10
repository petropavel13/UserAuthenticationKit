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

import UIKit

open class BasePassCodeDotView: UIView {

    private var appearanceForState: [PassCodeStepViewState: BaseAppearance] = [:]

    open override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}

extension BasePassCodeDotView: PassCodeStepView {

    public var view: UIView {
        return self
    }

    public func applyAppearance(for state: PassCodeStepViewState) {
        guard let appearance = appearanceForState[state] else {
            return
        }

        configureBase(appearance: appearance)
    }
}

extension BasePassCodeDotView {

    open class BaseAppearance {

        let fillColor: UIColor
        let borderColor: UIColor
        let borderWidth: CGFloat

        init(fillColor: UIColor = .lightGray,
             borderColor: UIColor = .white,
             borderWidth: CGFloat = 1) {

            self.fillColor = fillColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }
    }

    public func configureBase(appearance: BaseAppearance) {
        layer.backgroundColor = appearance.fillColor.cgColor
        layer.borderWidth = appearance.borderWidth
        layer.borderColor = appearance.borderColor.cgColor
    }

    public func set(appearance: BaseAppearance, for state: PassCodeStepViewState) {
        appearanceForState[state] = appearance
    }
}

public extension BasePassCodeDotView.BaseAppearance {

    func copyWith(fillColor: UIColor? = nil,
                  borderColor: UIColor? = nil,
                  borderWidth: CGFloat? = nil) -> BasePassCodeDotView.BaseAppearance {

        return BasePassCodeDotView.BaseAppearance(fillColor: fillColor ?? self.fillColor,
                                                  borderColor: borderColor ?? self.borderColor,
                                                  borderWidth: borderWidth ?? self.borderWidth)
    }
}
