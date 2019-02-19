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

@available(iOS 9.0, *)
open class BasePassCodeKeyboardViewController<ViewModel: BasePassCodeViewModel>: BasePassCodeViewController<ViewModel> {

    let currentStateTitleLabel = UILabel()

    let centerContentContainer = UIView()

    private(set) lazy var passCodeStepsView = createPassCodeStepsView()

    private(set) lazy var passCodeKeyboardView = createPassCodeKeyboardView()
    private(set) lazy var passCodeCollectionProvider = createPassCodeProvider()

    public var animator: Animator? {
        didSet {
            passCodeCollectionProvider.animator = animator
        }
    }

    open var shouldBindProviderOnDidAppear: Bool {
        return animator != nil
    }

    open override func addViews() {
        super.addViews()

        centerContentContainer.addSubview(currentStateTitleLabel)
        centerContentContainer.addSubview(passCodeStepsView.view)
        centerContentContainer.addSubview(passCodeKeyboardView)

        view.addSubview(centerContentContainer)
    }

    open func configureCurrentStateTitleLabelLayout() {
        currentStateTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stateTitleLabelConstraints = [
            currentStateTitleLabel.leadingAnchor.constraint(equalTo: centerContentContainer.leadingAnchor),
            currentStateTitleLabel.trailingAnchor.constraint(equalTo: centerContentContainer.trailingAnchor),
            currentStateTitleLabel.topAnchor.constraint(equalTo: centerContentContainer.topAnchor)
        ]

        NSLayoutConstraint.activate(stateTitleLabelConstraints)
    }

    open func configureStepsViewLayout() {
        passCodeStepsView.view.translatesAutoresizingMaskIntoConstraints = false

        let stepViewConstraints = [
            passCodeStepsView.view.leadingAnchor.constraint(equalTo: centerContentContainer.leadingAnchor),
            passCodeStepsView.view.trailingAnchor.constraint(equalTo: centerContentContainer.trailingAnchor),
            passCodeStepsView.view.topAnchor.constraint(equalTo: currentStateTitleLabel.bottomAnchor, constant: 16),
            passCodeStepsView.view.heightAnchor.constraint(equalToConstant: 36)
        ]

        NSLayoutConstraint.activate(stepViewConstraints)
    }

    open func configureKeyboardViewLayout() {
        passCodeKeyboardView.translatesAutoresizingMaskIntoConstraints = false

        let keyboardViewConstraints = [
            passCodeKeyboardView.leadingAnchor.constraint(equalTo: centerContentContainer.leadingAnchor),
            passCodeKeyboardView.trailingAnchor.constraint(equalTo: centerContentContainer.trailingAnchor),
            passCodeKeyboardView.bottomAnchor.constraint(equalTo: centerContentContainer.bottomAnchor),
            passCodeKeyboardView.topAnchor.constraint(equalTo: passCodeStepsView.view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(keyboardViewConstraints)
    }

    override open func configureLayout() {
        super.configureLayout()

        configureCurrentStateTitleLabelLayout()
        configureStepsViewLayout()
        configureKeyboardViewLayout()

        centerContentContainer.translatesAutoresizingMaskIntoConstraints = false

        let contentContainerConstraints = [
            centerContentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            centerContentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            centerContentContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerContentContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ]

        NSLayoutConstraint.activate(contentContainerConstraints)
    }

    open override func bindViews() {
        super.bindViews()

        updateStateTitleLabel()

        if !shouldBindProviderOnDidAppear {
            configurePassCodeKeyboardView()
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard shouldBindProviderOnDidAppear else {
            return
        }

        configurePassCodeKeyboardView()
    }

    open func configurePassCodeKeyboardView() {
        passCodeKeyboardView.provider = passCodeCollectionProvider
    }

    open func createPassCodeKeyboardView() -> BasePassCodeKeyboardView {
        return BasePassCodeKeyboardView()
    }

    open func createPassCodeProvider() -> PassCodeCollectionProvider {
        return PassCodeCollectionProvider { [weak self] in
            self?.handle(passCodeButtonItem: $0.data)
        }
    }

    open func createPassCodeStepsView() -> PassCodeStepsView {
        return BasePassCodeStepsView(stepsCount: viewModel.passCodeLength)
    }

    public func handle(passCodeButtonItem: PassCodeButtonItem) {
        switch passCodeButtonItem {
        case let .digit(number):
            passCodeStepsView.stepForward()
            viewModel.didEnter(digit: String(number))
        case .backspace:
            passCodeStepsView.stepBackward()
            viewModel.didRemoveLastDigit()
        case .biometrics:
            viewModel.didRequestBiometricsAuthentication()
        case let .custom(passCodeButtonRepresentable):
            handle(custom: passCodeButtonRepresentable)
        }
    }

    open func handle(custom: PassCodeButtonRepresentable) {
        // handle in subclass
    }

    open override func invalid(passCode: String, failedRules: [PassCodeValidationRule]) {
        super.invalid(passCode: passCode, failedRules: failedRules)

        passCodeStepsView.resetState()
        viewModel.resetEnteredPassCode()
    }

    open override func transition(to state: PassCodeState) {
        super.transition(to: state)

        switch state {
        case let .enter(error, _):
            if error != nil {
                passCodeStepsView.moveToFinishedState(isSuccess: false, animated: true) {
                    self.onDidCompletePassCodeStepsViewAnimation()
                }
            }
        case let .finished(error):
            passCodeStepsView.moveToFinishedState(isSuccess: error == nil, animated: true) {
                self.onDidCompletePassCodeStepsViewAnimation()
                self.onDidCompleFlow()
            }
        }

        updateStateTitleLabel()
    }

    open func onDidCompletePassCodeStepsViewAnimation() {
        passCodeStepsView.resetState()
    }

    open func onDidCompleFlow() {
        // override in subclass
    }

}

@available(iOS 9.0, *)
private extension BasePassCodeKeyboardViewController {

    func updateStateTitleLabel() {
        currentStateTitleLabel.text = viewModel.stateTitle
    }

}
