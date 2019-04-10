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

open class BasePassCodeViewSource: ViewSource<PassCodeButtonItem, BasePassCodeButton> {

    open override func update(view: BasePassCodeButton, data: PassCodeButtonItem, index: Int) {
        configureAppearance(of: view)
        view.buttonItem = data
    }

    open override func view(data: PassCodeButtonItem, index: Int) -> BasePassCodeButton {
        let button = reuseManager.dequeue(createButton(for: data))
        update(view: button, data: data, index: index)
        return button
    }

    open func createButton(for item: PassCodeButtonItem) -> BasePassCodeButton {
        return BasePulsePassCodeButton(buttonItem: item)
    }

    open func configureAppearance(of button: BasePassCodeButton) {
        let normalAppearance = appearance(for: button.buttonItem, in: .normal)
        let hightlightedAppearance = appearance(for: button.buttonItem, in: .highlighted)
        button.set(appearance: normalAppearance, for: .normal)
        button.set(appearance: hightlightedAppearance, for: .highlighted)
    }

    open func appearance(for item: PassCodeButtonItem,
                         in state: UIControl.State) -> BasePassCodeButton.BaseAppearance {

        switch state {
        case .normal:
            return .defaultDigitAppearance

        case .highlighted:
            return .defaultPressedDigitAppearance

        default:
            return .defaultDigitAppearance
        }
    }
}
