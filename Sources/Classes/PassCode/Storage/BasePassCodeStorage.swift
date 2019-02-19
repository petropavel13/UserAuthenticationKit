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

private extension String {

    static let hasSavedPassCodeKey = "UserAuthenticationKit.hasSavedPassCodeKey"

}

open class BasePassCodeStorage: PassCodeStorage {

    private let appInstallStorage: UserDefaults
    private let securePassCodeStorage: PassCodeStorage

    public init(appInstallStorage: UserDefaults = .standard,
                securePassCodeStorage: PassCodeStorage = BaseKeychainPassCodeStorage()) {

        self.appInstallStorage = appInstallStorage
        self.securePassCodeStorage = securePassCodeStorage
    }

    open var hasPasscode: Bool {
        return appInstallStorage.bool(forKey: .hasSavedPassCodeKey) && securePassCodeStorage.hasPasscode
    }

    open func store(passCode: String) {
        securePassCodeStorage.store(passCode: passCode)
    }

    open func loadAndCompare(with passCode: String) -> Bool {
        return securePassCodeStorage.loadAndCompare(with: passCode)
    }

    open func clear() {
        appInstallStorage.set(false, forKey: .hasSavedPassCodeKey)
        securePassCodeStorage.clear()
    }

}
