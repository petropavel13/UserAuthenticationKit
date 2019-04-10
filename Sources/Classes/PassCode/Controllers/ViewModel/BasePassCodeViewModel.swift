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

open class BasePassCodeViewModel {
    public struct Settings {
        let passCodeLength: UInt
        let resetWhenEnterInBackground: Bool
        let requestBiometricsAuthWhenEnterForeground: Bool
    }

    private let settings: Settings
    private var flowCoordinator: PassCodeFlowCoordinator
    private let passCodeStorage: PassCodeStorage
    private let inputValidator: PassCodeValidator
    private let notificationCenter = NotificationCenter.default

    weak var delegate: PassCodeViewModelDelegate?

    private var currentPassCode = ""

    private var didEnterInBackgroundObserver: NSObjectProtocol?
    private var willEnterInForegroundObserver: NSObjectProtocol?

    public init(flowCoordinator: PassCodeFlowCoordinator,
                passCodeStorage: PassCodeStorage = BasePassCodeStorage(),
                settings: Settings = .defaultSettings,
                inputValidator: PassCodeValidator = BasePassCodeValidator(validationRules: [])) {

        self.flowCoordinator = flowCoordinator
        self.passCodeStorage = passCodeStorage
        self.settings = settings
        self.inputValidator = inputValidator

        self.flowCoordinator.delegate = self

        if settings.resetWhenEnterInBackground {
            bindToDidEnterBackgroundNotifications()
        }

        if settings.requestBiometricsAuthWhenEnterForeground {
            bindToWillEnterForegroundNotifications()
        }
    }

    deinit {
        notificationCenter.remove(nillableObserver: didEnterInBackgroundObserver)
        notificationCenter.remove(nillableObserver: willEnterInForegroundObserver)
    }
}

extension BasePassCodeViewModel: PassCodeFlowDelegate {
    public func flowDidTransition(to state: PassCodeState) {
        delegate?.transition(to: state)

        resetEnteredPassCode()
    }
}

public extension BasePassCodeViewModel {
    var passCodeLength: UInt {
        return settings.passCodeLength
    }

    var enteredDigitsCount: UInt {
        return UInt(currentPassCode.count)
    }

    var stateTitle: String {
        return flowCoordinator.currentStateTitle
    }

    var canAuthenticateWithBiometrics: Bool {
        guard let biometricsFlowCoordinator = flowCoordinator as? PassCodeBiometricsFlowCoordinator else {
            return false
        }

        return biometricsFlowCoordinator.canAuthenticateWithBiometrics
    }

    func didEnter(digit: String) {
        currentPassCode.append(digit)
        validateCurrentPassCode()
    }

    func didRemoveLastDigit() {
        currentPassCode.removeLast()
    }

    func resetEnteredPassCode() {
        currentPassCode = ""
    }

    func resetStoredPassCode() {
        passCodeStorage.clear()
    }

    func startFlow() {
        let newState = flowCoordinator.startFlow()
        delegate?.transition(to: newState)
    }

    func didRequestBiometricsAuthentication() {
        if let biometricsCoordinator = flowCoordinator as? PassCodeBiometricsFlowCoordinator {
            let newState = biometricsCoordinator.authenticateUsingBiometrics()
            delegate?.transition(to: newState)
        }
    }

    func update(flowCoordinator: PassCodeFlowCoordinator) {
        self.flowCoordinator = flowCoordinator
    }
}

public extension BasePassCodeViewModel.Settings {
    static var defaultSettings: BasePassCodeViewModel.Settings {
        return .init(passCodeLength: DefaultSettings.PassCodeSettings.passCodeLength,
                     resetWhenEnterInBackground: false,
                     requestBiometricsAuthWhenEnterForeground: true)
    }
}

private extension BasePassCodeViewModel {
    func validateCurrentPassCode() {
        let failedRules = inputValidator.validate(passCode: currentPassCode)

        if !failedRules.isEmpty {
            delegate?.invalid(passCode: currentPassCode, failedRules: failedRules)
        } else if passCodeLength == UInt(currentPassCode.count) {
            let newState = flowCoordinator.didFinishEnter(passCode: currentPassCode)
            flowDidTransition(to: newState)
        }
    }

    func resetFlow() {
        resetEnteredPassCode()
        let newState = flowCoordinator.reset()
        delegate?.transition(to: newState)
    }

    func bindToDidEnterBackgroundNotifications() {
        didEnterInBackgroundObserver = notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] _ in
                                                                        self?.resetFlow()
        }
    }

    func bindToWillEnterForegroundNotifications() {
        willEnterInForegroundObserver = notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                       object: nil,
                                                                       queue: .main) { [weak self] _ in
                                                                        self?.didRequestBiometricsAuthentication()
        }
    }
}

private extension NotificationCenter {
    func remove(nillableObserver: NSObjectProtocol?) {
        if let observer = nillableObserver {
            removeObserver(observer)
        }
    }
}
