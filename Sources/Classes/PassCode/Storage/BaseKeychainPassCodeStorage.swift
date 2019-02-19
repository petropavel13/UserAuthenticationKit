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

import KeychainAccess
import CryptoSwift

private extension String {

    static let passCodeHashKey = "UserAuthenticationKit.passCodeHashKey"

}

open class BaseKeychainPassCodeStorage: PassCodeStorage {

    private let keychain: Keychain

    public init(keychainServiceString: String) {
        self.keychain = Keychain(service: keychainServiceString).synchronizable(false)
    }

    open var hasPasscode: Bool {
        return keychain[.passCodeHashKey] != nil
    }

    open func store(passCode: String) {
        keychain[.passCodeHashKey] = hash(of: passCode)
    }

    open func loadAndCompare(with passCode: String) -> Bool {
        return keychain[.passCodeHashKey] == hash(of: passCode)
    }

    open func clear() {
        keychain[.passCodeHashKey] = nil
    }

    open func hash(of passCode: String) -> String {
        return passCode.sha256()
    }

}

public extension BaseKeychainPassCodeStorage {

    convenience init(bundle: Bundle = .main) {
        self.init(keychainServiceString: bundle.bundleIdentifier ?? "")
    }

}
