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

open class BasePassCodeChangeFlowCoordinator: PassCodeFlowCoordinator {
    public weak var delegate: PassCodeFlowDelegate?

    open var initialState: PassCodeState {
        return .enter(error: nil)
    }

    public var currentStateTitle: String {
        switch (currentInputState.isNew, currentInputState.isRepeat) {
        case (false, _):
            return enterCurrentCodeTitle

        case (true, false):
            return enterNewCodeTitle

        case (true, true):
            return repeatEnterCodeTitle
        }
    }
    
    public private(set) var remainingAttempts: UInt

    public let flowType: PassCodeFlowType = .change

    private var didEnterOldPassCode: Bool = false

    private let enterCurrentCodeTitle: String
    private let enterNewCodeTitle: String
    private let repeatEnterCodeTitle: String

    private var currentInputState: CodeInputState = .current

    private let maxPassCodeEnterAttempts: UInt
    private let passCodeStorage: PassCodeStorage

    private var firstPassCode: String?

    public init(enterCurrentCodeTitle: String,
                enterNewCodeTitle: String,
                repeatEnterCodeTitle: String,
                maxPassCodeEnterAttempts: UInt = DefaultSettings.PassCodeSettings.maxPassCodeEnterAttempts,
                passCodeStorage: PassCodeStorage = BasePassCodeStorage()) {

        self.enterCurrentCodeTitle = enterCurrentCodeTitle
        self.enterNewCodeTitle = enterNewCodeTitle
        self.repeatEnterCodeTitle = repeatEnterCodeTitle
        self.maxPassCodeEnterAttempts = maxPassCodeEnterAttempts
        self.passCodeStorage = passCodeStorage
        self.remainingAttempts = maxPassCodeEnterAttempts
    }

    open func startFlow() -> PassCodeState {
        return initialState
    }

    open func didFinishEnter(passCode: String) -> PassCodeState {
        switch (didEnterOldPassCode, firstPassCode) {
        case (false, _):
            if passCodeStorage.loadAndCompare(with: passCode) {
                return onDidEnterCorrectCurrentCode()
            } else {
                remainingAttempts -= 1

                guard remainingAttempts > 0 else {
                    return onDidSpendLastTryToEnterCurrentCode()
                }

                return onDidEnterIncorrectCurrentPassCode()
            }

        case (true, nil):
            return onDidEnter(firstPassCode: passCode)

        case let (true, firstPassCode?):
            if firstPassCode == passCode {
                passCodeStorage.store(passCode: passCode)

                return .finished(error: nil, flowType: flowType)
            } else {
                return onDidEnterIncorrectRepeatPassCode()
            }
        }
    }

    open func reset() -> PassCodeState {
        didEnterOldPassCode = false
        firstPassCode = nil
        return initialState
    }

    open func onDidEnterCorrectCurrentCode() -> PassCodeState {
        didEnterOldPassCode = true
        currentInputState = [.new]
        return .enter(error: nil)
    }

    open func onDidSpendLastTryToEnterCurrentCode() -> PassCodeState {
        return .finished(error: .tooManyAttempts, flowType: flowType)
    }

    open func onDidEnterIncorrectCurrentPassCode() -> PassCodeState {
        return .enter(error: .wrongCode(attemptsRemaining: remainingAttempts))
    }

    open func onDidEnter(firstPassCode: String) -> PassCodeState {
        self.firstPassCode = firstPassCode
        currentInputState = [.new, .repeat]
        return .enter(error: nil)
    }

    open func onDidEnterIncorrectRepeatPassCode() -> PassCodeState {
        return .enter(error: .codesNotMatch)
    }
}
