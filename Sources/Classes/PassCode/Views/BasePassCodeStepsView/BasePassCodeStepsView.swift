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

open class BasePassCodeStepsView: CollectionView, PassCodeStepsView {

    private let dataSource: PassCodeStepsDataSource

    private var lastFilledStepIndex: Int

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(stepsCount: UInt) {
        dataSource = PassCodeStepsDataSource(numberOfSteps: stepsCount)
        lastFilledStepIndex = -1

        super.init(frame: .zero)

        provider = createProvider()
    }

    // MARK: - PassCodeStepsView

    public var view: UIView {
        return self
    }

    open func stepForward() {
        let nextStepIndex = lastFilledStepIndex + 1

        guard nextStepIndex < dataSource.numberOfItems else {
            assertionFailure("Last step has been already reached!")
            return
        }

        lastFilledStepIndex = nextStepIndex
        dataSource.update(state: .filled, at: nextStepIndex)
    }

    open func stepBackward() {
        let prevStepIndex = lastFilledStepIndex - 1

        guard prevStepIndex >= 0 else {
            assertionFailure("First step has been already reached!")
            return
        }

        lastFilledStepIndex = prevStepIndex
        dataSource.update(state: .normal, at: prevStepIndex)
    }

    open func moveToFinishedState(isSuccess: Bool,
                                  animated: Bool,
                                  completion: (() -> Void)?) {

        dataSource.updateItemsState(newState: .highlighted(isValid: isSuccess))

        if animated && !isSuccess {
            shakeAnimation(completion: completion)
        } else {
            completion?()
        }
    }

    open func resetState() {
        lastFilledStepIndex = -1
        dataSource.updateItemsState(newState: .normal)
    }

    open func createProvider() -> Provider & LayoutSettableProvider {
        let stepViewConfiguratorClosure: (BasePassCodeDotView) -> Void = {
            $0.set(appearance: .defaultNormalAppearance, for: .normal)
            $0.set(appearance: .defaultFilledAppearance, for: .filled)
            $0.set(appearance: .defaultInvalidHighlightedAppearance, for: .highlighted(isValid: false))
            $0.set(appearance: .defaultValidHighlightedAppearance, for: .highlighted(isValid: true))
        }

        let viewSource = PassCodeStepsViewSource(viewConfiguratorClosure: stepViewConfiguratorClosure)

        return PassCodeStepsCollectionProvider(dataSource: dataSource,
                                               viewSource: viewSource)
    }

    open func configureBase(appearance: BaseAppearance) {
        guard let layoutableProvider = provider as? LayoutSettableProvider else {
            assertionFailure("Attempt to configure \(BasePassCodeStepsView.self) whose provider doesn't implement \(LayoutSettableProvider.self)!")
            return
        }

        layoutableProvider.layout = appearance.collectionLayout
    }

}

private extension UIView {

    func shakeAnimation(withDuration duration: CFTimeInterval = 600, completion: (() -> Void)?) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration / 1_000
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }

}

public extension BasePassCodeDotView.BaseAppearance {

    static var defaultNormalAppearance: BasePassCodeDotView.BaseAppearance {
        return BasePassCodeDotView.BaseAppearance(fillColor: .clear,
                                                  borderColor: .lightGray,
                                                  borderWidth: 1)
    }

    static var defaultFilledAppearance: BasePassCodeDotView.BaseAppearance {
        return BasePassCodeDotView.BaseAppearance(fillColor: .lightGray,
                                                  borderColor: .clear,
                                                  borderWidth: 0)
    }

    static var defaultInvalidHighlightedAppearance: BasePassCodeDotView.BaseAppearance {
        return BasePassCodeDotView.BaseAppearance(fillColor: .red,
                                                  borderColor: .clear,
                                                  borderWidth: 0)
    }

    static var defaultValidHighlightedAppearance: BasePassCodeDotView.BaseAppearance {
        return BasePassCodeDotView.BaseAppearance(fillColor: .green,
                                                  borderColor: .clear,
                                                  borderWidth: 0)
    }

}

extension BasePassCodeStepsView {

    open class BaseAppearance {
        let interitemSpacing: CGFloat

        init(interitemSpacing: CGFloat = DefaultAppearance.PassCodeStepsCollectionProvider.interitemSpacing) {
            self.interitemSpacing = interitemSpacing
        }

        open var collectionLayout: Layout {
            return .defaultPassCodeStepsLayout(interitemSpacing: interitemSpacing)
        }
    }

}
