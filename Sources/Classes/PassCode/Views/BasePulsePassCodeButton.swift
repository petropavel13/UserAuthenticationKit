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

open class BasePulsePassCodeButton: BasePassCodeButton {

    private var hightlightAnimationInProgress = false

    private var applyNormalStateWhenFinishHighlight = false

    open override func configureBase(appearance: BaseAppearance) {
        // without background color update
        configureBaseTitleAppearance(with: appearance)
        configureBaseBorderAppearance(with: appearance)
    }

    open override func applyAppearance(for state: State) {
        guard !(state == .normal && hightlightAnimationInProgress) else {
            applyNormalStateWhenFinishHighlight = true
            return
        }

        let newBackgroundColor = baseAppearance(for: state).backgroundColor

        if state == .highlighted {
            hightlightAnimationInProgress = true

            applyPulseAnimation(toValue: newBackgroundColor) {
                self.hightlightAnimationInProgress = false
                self.backgroundColor = newBackgroundColor

                if self.applyNormalStateWhenFinishHighlight {
                    self.applyAppearance(for: .normal)
                    self.applyNormalStateWhenFinishHighlight = false
                }
            }
        } else {
            applyPulseAnimation(toValue: newBackgroundColor) {
                self.backgroundColor = newBackgroundColor
            }
        }

        configureBase(appearance: baseAppearance(for: state))
    }

}

private extension BasePulsePassCodeButton {

    func applyPulseAnimation(toValue newBackgroundColor: UIColor,
                             completion: @escaping () -> Void) {

        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.toValue = newBackgroundColor.cgColor
        colorAnimation.duration = 0.1
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = .forwards

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(colorAnimation, forKey: "ColorPulse")
        CATransaction.commit()
    }

}
