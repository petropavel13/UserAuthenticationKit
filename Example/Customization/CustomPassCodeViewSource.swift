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

import UserAuthenticationKit

final class CustomPassCodeViewSource: BasePassCodeViewSource {
    override func appearance(for item: PassCodeButtonItem,
                             in state: UIControl.State) -> BasePassCodeButton.BaseAppearance {
        guard case let .custom(buttonRepresentable as CustomPassCodeButtonItem) = item else {
            return super.appearance(for: item, in: state)
        }

        switch buttonRepresentable {
        case .forgotPassword:
            switch state {
            case .normal:
                return .forgotPasswordTitleAppearance
            case .highlighted:
                return .forgotPasswordPressedTitleAppearance
            default:
                return .forgotPasswordTitleAppearance
            }
        case .logout:
            switch state {
            case .normal:
                return .forgotPasswordTitleAppearance
            case .highlighted:
                return .forgotPasswordPressedTitleAppearance
            default:
                return .forgotPasswordTitleAppearance
            }
        }
    }
}

private extension BasePassCodeButton.BaseAppearance {
    static var forgotPasswordTitleAppearance: BasePassCodeButton.BaseAppearance {
        return BasePassCodeButton.BaseAppearance
            .defaultDigitAppearance
            .copyWith(titleFont: .systemFont(ofSize: 15, weight: .medium),
                      borderColor: .clear)
    }

    static var forgotPasswordPressedTitleAppearance: BasePassCodeButton.BaseAppearance {
        return BasePassCodeButton.BaseAppearance
            .forgotPasswordTitleAppearance
            .update {
                $0.copyWith(titleColor: $0.titleColor.withAlphaComponent(0.5))
            }
    }
}
