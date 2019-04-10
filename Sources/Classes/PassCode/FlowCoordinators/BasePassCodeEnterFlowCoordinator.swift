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

@available(tvOS 10.0, *)
open class BasePassCodeEnterFlowCoordinator: PassCodeBiometricsFlowCoordinator {
    private let authenticationParameters: BiometricsAuthenticationParameters
    private let maxPassCodeEnterAttempts: UInt
    private let biometricsService: BiometricsService
    private let passCodeStorage: PassCodeStorage

    public weak var delegate: PassCodeFlowDelegate?

    open var initialState: PassCodeState {
        return .enter(error: nil)
    }

    public let currentStateTitle: String

    public private(set) var remainingAttempts: UInt

    public let flowType: PassCodeFlowType = .enter

    public init(authenticationParameters: BiometricsAuthenticationParameters,
                title: String,
                maxPassCodeEnterAttempts: UInt = DefaultSettings.PassCodeSettings.maxPassCodeEnterAttempts,
                biometricsService: BiometricsService = BaseBiometricsService(),
                passCodeStorage: PassCodeStorage = BasePassCodeStorage()) {

        if maxPassCodeEnterAttempts == 0 {
            assertionFailure("User should have at least one attempt!")
        }

        self.authenticationParameters = authenticationParameters
        self.maxPassCodeEnterAttempts = maxPassCodeEnterAttempts
        self.currentStateTitle = title
        self.biometricsService = biometricsService
        self.passCodeStorage = passCodeStorage

        self.remainingAttempts = maxPassCodeEnterAttempts
    }

    open func startFlow() -> PassCodeState {
        return authenticateUsingBiometrics()
    }

    open func didFinishEnter(passCode: String) -> PassCodeState {
        if passCodeStorage.loadAndCompare(with: passCode) {
            return .finished(error: nil, flowType: flowType)
        } else {
            remainingAttempts -= 1

            guard remainingAttempts > 0 else {
                return onDidSpendLastTryToEnterCurrentCode()
            }

            return onDidEnterIncorrectCurrentPassCode()
        }
    }

    open func reset() -> PassCodeState {
        remainingAttempts = maxPassCodeEnterAttempts
        return initialState
    }

    // MARK: - PassCodeBiometricsFlowCoordinator

    open var canAuthenticateWithBiometrics: Bool {
        return biometricsService.canAuthenticateWithBiometrics
    }

    open func authenticateUsingBiometrics() -> PassCodeState {
        if biometricsService.canAuthenticateWithBiometrics {
            biometricsService.authenticateWithBiometrics(with: authenticationParameters) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.onDidFinishAuthenticaWithBiometrics(success: success, error: error)
                }
            }
        }

        return .enter(error: nil)
    }

    open func onDidFinishAuthenticaWithBiometrics(success: Bool, error: Error?) {
        let newState: PassCodeState

        if success {
            newState = .finished(error: nil, flowType: self.flowType)
        } else {
            newState = onDidFailedAuthenticateUsingBiometrics()
        }

        delegate?.flowDidTransition(to: newState)
    }

    open func onDidFailedAuthenticateUsingBiometrics() -> PassCodeState {
        return initialState
    }

    open func onDidSpendLastTryToEnterCurrentCode() -> PassCodeState {
        return .finished(error: .tooManyAttempts, flowType: flowType)
    }

    open func onDidEnterIncorrectCurrentPassCode() -> PassCodeState {
        return .enter(error: .wrongCode(attemptsRemaining: remainingAttempts))
    }
}
