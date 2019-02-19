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

public final class PassCodeStepsViewSource<StepView: PassCodeStepView & UIView>: ViewSource<PassCodeStepViewState, StepView> {

    public typealias ViewConfiguratorClosure = (StepView) -> Void

    private let viewConfiguratorClosure: ViewConfiguratorClosure?

    public init(viewConfiguratorClosure: ViewConfiguratorClosure? = nil) {
        self.viewConfiguratorClosure = viewConfiguratorClosure

        super.init()
    }

    override public func update(view: StepView, data: PassCodeStepViewState, index: Int) {
        super.update(view: view, data: data, index: index)
        viewConfiguratorClosure?(view)
        view.applyAppearance(for: data)
    }

}
