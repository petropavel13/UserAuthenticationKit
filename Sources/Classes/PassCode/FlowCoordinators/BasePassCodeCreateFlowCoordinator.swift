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

open class BasePassCodeCreateFlowCoordinator: PassCodeFlowCoordinator {

    public var delegate: PassCodeFlowDelegate?

    open var initialState: PassCodeState {
        return .enter(error: nil, inputState: [.new])
    }

    public let currentStateTitle: String

    private let passCodeStorage: PassCodeStorage

    private var firstPassCode: String?

    public init(title: String, passCodeStorage: PassCodeStorage = BasePassCodeStorage()) {
        self.currentStateTitle = title
        self.passCodeStorage = passCodeStorage
    }

    open func startFlow() -> PassCodeState {
        return initialState
    }

    open func didFinishEnter(passCode: String) -> PassCodeState {
        if let firstPassCode = firstPassCode {
            if firstPassCode == passCode {
                passCodeStorage.store(passCode: passCode)

                return .finished(error: nil)
            } else {
                return onDidEnterIncorrectSecondPassCode()
            }
        } else {
            firstPassCode = passCode
            return onDidEnterFirstPassCode()
        }
    }

    open func reset() -> PassCodeState {
        firstPassCode = nil
        return initialState
    }

    open func onDidEnterIncorrectSecondPassCode() -> PassCodeState {
        return .enter(error: .codesNotMatch, inputState: [.new])
    }

    open func onDidEnterFirstPassCode() -> PassCodeState {
        return .enter(error: nil, inputState: [.new, .repeat])
    }

}
