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

public struct CodeInputState: OptionSet {
    public let rawValue: Int

    /// Typing currently used pass code (login or change flow)
    static let current = CodeInputState(uncheckedRawValue: 1 << 0)

    /// Typing new pass code (create or change flow)
    static let new = CodeInputState(uncheckedRawValue: 1 << 1)

    /// Typing new or current pass code again (any flow)
    static let `repeat` = CodeInputState(uncheckedRawValue: 1 << 2)

    /// Presenting biometrics authentication
    static let biometrics = CodeInputState(uncheckedRawValue: 1 << 3)

    private static let valuesRange = CodeInputState.current.rawValue...CodeInputState.biometrics.rawValue

    public init(rawValue: Int) {
        // Swift (?) bug. called from contains method with rawValue = 0
//        precondition(CodeInputState.valuesRange ~= rawValue)
        self.rawValue = rawValue
    }

    private init(uncheckedRawValue: Int) {
        self.rawValue = uncheckedRawValue
    }

    var isCurrent: Bool {
        return contains(.current)
    }

    var isNew: Bool {
        return contains(.new)
    }

    var isRepeat: Bool {
        return contains(.repeat)
    }

    var isBiometrics: Bool {
        return contains(.biometrics)
    }
}

public enum PassCodeState {
    case enter(error: PassCodeFlowError?)
    case finished(error: PassCodeFlowError?, flowType: PassCodeFlowType)
}

public extension PassCodeState {
    var flowError: PassCodeFlowError? {
        switch self {
        case let .enter(error):
            return error

        case let .finished(error, _):
            return error
        }
    }
}
