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

public final class PassCodeStepsCollectionProvider<StepView: PassCodeStepView>: BasicProvider<PassCodeStepViewState, StepView> {
    public typealias ViewSourceType = ViewSource<PassCodeStepViewState, StepView>
    public typealias DataSourceType = DataSource<PassCodeStepViewState>
    public typealias SizeSourceType = SizeSource<PassCodeStepViewState>

    public init(dataSource: DataSourceType,
                viewSource: ViewSourceType = PassCodeStepsViewSource<StepView>(),
                sizeSource: SizeSourceType = .defaultPassCodeItemSizeSource,
                layout: Layout = .defaultPassCodeStepsLayout(),
                animator: Animator? = nil) {

        super.init(dataSource: dataSource,
                   viewSource: viewSource,
                   sizeSource: sizeSource,
                   layout: layout,
                   animator: animator)
    }
}

public extension DefaultAppearance {
    enum PassCodeStepsCollectionProvider {
        public static let itemSize: CGFloat = 12
        public static let interitemSpacing: CGFloat = 24
    }
}

private extension CGFloat {
    static let itemSize = DefaultAppearance.PassCodeStepsCollectionProvider.itemSize
}

public extension SizeSource where Data == PassCodeStepViewState {
    static var defaultPassCodeItemSizeSource: SizeSource<Data> {
        return ClosureSizeSource { _, _, _ in
            CGSize(width: .itemSize, height: .itemSize)
        }
    }
}

public extension Layout {
    static func defaultPassCodeStepsLayout(interitemSpacing: CGFloat = DefaultAppearance
        .PassCodeStepsCollectionProvider
        .interitemSpacing) -> Layout {
        return FlowLayout(lineSpacing: 0,
                          interitemSpacing: interitemSpacing,
                          justifyContent: .center,
                          alignItems: .center,
                          alignContent: .center)
    }
}
