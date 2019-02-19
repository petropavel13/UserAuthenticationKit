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

open class BasePassCodeButton: UIButton {

    var buttonItem: PassCodeButtonItem {
        didSet {
            setImage(buttonItem.image, for: [])
            setTitle(buttonItem.title, for: [])
        }
    }

    public init(buttonItem: PassCodeButtonItem) {
        self.buttonItem = buttonItem

        super.init(frame: .zero)

        bindTouchEvents()
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    public var appearanceForState: [UIControl.State: BaseAppearance] = [:] {
        didSet {
            applyAppearance(for: state)
        }
    }

    open func configureBaseTitleAppearance(with appearance: BaseAppearance) {
        titleLabel?.numberOfLines = 0
        titleLabel?.font = appearance.titleFont
        setTitleColor(appearance.titleColor, for: state)
    }

    open func configureBaseBorderAppearance(with appearance: BaseAppearance) {
        layer.borderColor = appearance.borderColor.cgColor
        layer.borderWidth = appearance.borderWidth
    }

    open func configureBase(appearance: BaseAppearance) {
        backgroundColor = appearance.backgroundColor
        configureBaseTitleAppearance(with: appearance)
        configureBaseBorderAppearance(with: appearance)
    }

    open func applyAppearance(for state: State) {
        configureBase(appearance: baseAppearance(for: state))
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width / 2
    }

}

extension BasePassCodeButton {

    open class BaseAppearance {
        let titleFont: UIFont
        let titleColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor
        let borderWidth: CGFloat

        init(titleFont: UIFont = .systemFont(ofSize: 36),
             titleColor: UIColor = .black,
             backgroundColor: UIColor = .clear,
             borderColor: UIColor = .white,
             borderWidth: CGFloat = 1) {

            self.titleFont = titleFont
            self.titleColor = titleColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }
    }

    func set(appearance: BaseAppearance, for state: UIControl.State) {
        appearanceForState[state] = appearance
    }

    func appearance<A: BaseAppearance>(for state: UIControl.State) -> A? {
        return appearanceForState[state] as? A
    }

    func baseAppearance(for state: UIControl.State, default: BaseAppearance = BaseAppearance()) -> BaseAppearance {
        return appearanceForState[state] ?? appearanceForState[.normal] ?? `default`
    }

}

public extension BasePassCodeButton.BaseAppearance {

    static var defaultDigitAppearance: BasePassCodeButton.BaseAppearance {
        return BasePassCodeButton.BaseAppearance(titleFont: .systemFont(ofSize: 36),
                                                 titleColor: .white,
                                                 backgroundColor: .clear,
                                                 borderColor: .white,
                                                 borderWidth: 1)
    }

    static var defaultPressedDigitAppearance: BasePassCodeButton.BaseAppearance {
        return BasePassCodeButton.BaseAppearance
            .defaultDigitAppearance
            .copyWith(backgroundColor: UIColor.white.withAlphaComponent(0.5))
    }

    func copyWith(titleFont: UIFont? = nil,
                  titleColor: UIColor? = nil,
                  backgroundColor: UIColor? = nil,
                  borderColor: UIColor? = nil,
                  borderWidth: CGFloat? = nil) -> BasePassCodeButton.BaseAppearance {

        return BasePassCodeButton.BaseAppearance(titleFont: titleFont ?? self.titleFont,
                                                 titleColor: titleColor ?? self.titleColor,
                                                 backgroundColor: backgroundColor ?? self.backgroundColor,
                                                 borderColor: borderColor ?? self.borderColor,
                                                 borderWidth: borderWidth ?? self.borderWidth)
    }

    func update(updateClosure: (BasePassCodeButton.BaseAppearance) -> BasePassCodeButton.BaseAppearance) -> BasePassCodeButton.BaseAppearance {
        return updateClosure(self)
    }

}

private extension BasePassCodeButton {

    func bindTouchEvents() {
        addTarget(self, action: #selector(hightlightEvent), for: .touchDown)
        addTarget(self, action: #selector(unhighlightEvent), for: .touchUpInside)
        addTarget(self, action: #selector(unhighlightEvent), for: .touchUpOutside)
    }

    @objc func hightlightEvent() {
        applyAppearance(for: .highlighted)
    }

    @objc func unhighlightEvent() {
        applyAppearance(for: .normal)
    }

}
