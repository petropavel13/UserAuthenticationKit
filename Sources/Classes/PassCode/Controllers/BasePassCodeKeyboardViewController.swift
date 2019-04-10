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
    public let currentStateTitleLabel = UILabel()

    public let centerContentContainer = UIView()

    public var triggerHapticFeedbackOnError = true

    public private(set) lazy var passCodeStepsView = createPassCodeStepsView()

    public private(set) lazy var passCodeKeyboardView = createPassCodeKeyboardView()
    public private(set) lazy var passCodeCollectionProvider = createPassCodeProvider()

    private var feedbackGenerator: AnyObject?

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

        centerContentContainer.addSubviews(currentStateTitleLabel,
                                           passCodeStepsView,
                                           passCodeKeyboardView)

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
        passCodeStepsView.translatesAutoresizingMaskIntoConstraints = false

        let stepViewConstraints = [
            passCodeStepsView.leadingAnchor.constraint(equalTo: centerContentContainer.leadingAnchor),
            passCodeStepsView.trailingAnchor.constraint(equalTo: centerContentContainer.trailingAnchor),
            passCodeStepsView.topAnchor.constraint(equalTo: currentStateTitleLabel.bottomAnchor, constant: 16),
            passCodeStepsView.heightAnchor.constraint(equalToConstant: 36)
        ]

        NSLayoutConstraint.activate(stepViewConstraints)
    }

    open func configureKeyboardViewLayout() {
        passCodeKeyboardView.translatesAutoresizingMaskIntoConstraints = false

        let keyboardViewConstraints = [
            passCodeKeyboardView.leadingAnchor.constraint(equalTo: centerContentContainer.leadingAnchor),
            passCodeKeyboardView.trailingAnchor.constraint(equalTo: centerContentContainer.trailingAnchor),
            passCodeKeyboardView.bottomAnchor.constraint(equalTo: centerContentContainer.bottomAnchor),
            passCodeKeyboardView.topAnchor.constraint(equalTo: passCodeStepsView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(keyboardViewConstraints)
    }

    open func configureContentContainerLayout() {
        centerContentContainer.translatesAutoresizingMaskIntoConstraints = false

        let contentContainerConstraints = [
            centerContentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            centerContentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            centerContentContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerContentContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75)
        ]

        NSLayoutConstraint.activate(contentContainerConstraints)
    }

    override open func configureLayout() {
        super.configureLayout()

        configureCurrentStateTitleLabelLayout()
        configureStepsViewLayout()
        configureKeyboardViewLayout()
        configureContentContainerLayout()
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

        resetViewState()
        viewModel.resetEnteredPassCode()
    }

    open override func transition(to state: PassCodeState) {
        super.transition(to: state)

        if triggerHapticFeedbackOnError && state.flowError != nil {
            triggerErrorNotificationFeedbackIfPossible()
        }

        switch state {
        case let .enter(error):
            passCodeStepsView.moveToFinishedState(isSuccess: error == nil, animated: true) {
                self.onDidCompletePassCodeStepsViewAnimation()
                self.onDidCompleteEnterPassCode()
            }

        case let .finished(error, flowType):
            passCodeStepsView.moveToFinishedState(isSuccess: error == nil, animated: true) {
                self.onDidCompletePassCodeStepsViewAnimation()
                self.onDidCompleFlow(flowType: flowType)
            }
        }
    }

    open func onDidCompletePassCodeStepsViewAnimation() {
        updateStateTitleLabel()
    }

    open func resetViewState() {
        passCodeStepsView.resetState()
        updateStateTitleLabel()
    }
}

@available(iOS 9.0, *)
private extension BasePassCodeKeyboardViewController {
    func updateStateTitleLabel() {
        currentStateTitleLabel.text = viewModel.stateTitle
    }

    @available(iOS 10.0, *)
    func generateNotificationFeedback(feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(feedbackType)
        feedbackGenerator = generator
    }

    func triggerErrorNotificationFeedbackIfPossible() {
        if #available(iOS 10.0, *) {
            generateNotificationFeedback(feedbackType: .error)
        }
    }
}
