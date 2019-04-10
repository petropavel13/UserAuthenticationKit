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
import CollectionKit

final class PassCodeViewController: BasePassCodeKeyboardViewController<PassCodeViewModel> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViews() {
        animator = ScaleAnimator(animationDuration: 0.2)

        super.bindViews()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = .darkGray
        currentStateTitleLabel.textAlignment = .center
        currentStateTitleLabel.textColor = .white
    }

    override func createPassCodeProvider() -> PassCodeCollectionProvider {
        let customDataSource = PassCodeDataSource(leadingBottomItem: .custom(CustomPassCodeButtonItem.forgotPassword),
                                                  trailingBottomItem: .custom(CustomPassCodeButtonItem.logout))

        let customViewSource = CustomPassCodeViewSource()

        return PassCodeCollectionProvider(dataSource: customDataSource,
                                          viewSource: customViewSource,
                                          sizeSource: PassCodeFitParentSizeSource(lineSpacing: 24, interitemSpacing: 24),
                                          animator: animator) { [weak self] in
                                            self?.handle(passCodeButtonItem: $0.data)

        }
    }

    override func createPassCodeStepsView() -> PassCodeStepsView {
        return CustomPassCodeStepsView(stepsCount: viewModel.passCodeLength)
    }

    override func handle(custom item: PassCodeButtonRepresentable) {
        guard let customItem = item as? CustomPassCodeButtonItem else {
            return
        }

        switch customItem {
        case .forgotPassword:
            viewModel.onForgotPassword()
        case .logout:
            viewModel.logout()
        }
    }

    override func onDidCompleteEnterPassCode() {
        super.onDidCompleteEnterPassCode()

        passCodeStepsView.resetState()
    }

    override func onDidCompleFlow(flowType: PassCodeFlowType) {
        super.onDidCompleFlow(flowType: flowType)

        let message: String

        switch flowType {
        case .enter:
            message = "You are sucessfully logged in!"
        case .create:
            message = "Pass code created!"
        case .change:
            message = "You are sucessfully changed pass code!"
        case let .custom(flowId):
            message = "You are sucessfully finish \(flowId)!"
        }

        let alert = UIAlertController(title: "Finished!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.onDidFinishFlow(with: flowType)
        })

        present(alert, animated: true, completion: nil)
    }

    // MARK: - PassCodeViewModelDelegate

    override func invalid(passCode: String, failedRules: [PassCodeValidationRule]) {
        super.invalid(passCode: passCode, failedRules: failedRules)

        guard let firstFailedRule = failedRules.first else {
            return
        }

        let errorAlert = UIAlertController(title: firstFailedRule.errorTitle,
                                           message: firstFailedRule.errorMessage,
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        present(errorAlert, animated: true, completion: nil)
    }
}

private extension PassCodeViewController {
    func onDidFinishFlow(with flowType: PassCodeFlowType) {
        viewModel.update(flowCoordinator: nextFlowCoordinator(for: flowType))
        resetViewState()
    }

    func nextFlowCoordinator(for flowType: PassCodeFlowType) -> PassCodeFlowCoordinator {
        switch flowType {
        case .create:
            return BasePassCodeEnterFlowCoordinator()
        case .enter:
            return BasePassCodeChangeFlowCoordinator()
        case .change:
            viewModel.resetStoredPassCode()
            return BasePassCodeCreateFlowCoordinator()
        case .custom:
            fatalError("Not implemented")
        }
    }
}

private extension SimpleAnimator {
    convenience init(animationDuration: TimeInterval) {
        self.init()
        self.animationDuration = animationDuration
    }
}
