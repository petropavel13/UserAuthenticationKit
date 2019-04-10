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

public final class PassCodeCollectionProvider: BasicProvider<PassCodeButtonItem, BasePassCodeButton> {

    public typealias ViewSourceType = ViewSource<PassCodeButtonItem, BasePassCodeButton>
    public typealias DataSourceType = DataSource<PassCodeButtonItem>
    public typealias SizeSourceType = SizeSource<PassCodeButtonItem>

    public init(dataSource: DataSourceType = PassCodeDataSource(),
                viewSource: ViewSourceType = BasePassCodeViewSource(),
                sizeSource: SizeSourceType = PassCodeFitParentSizeSource.defaultPasscodeSizeSource,
                layout: Layout = .defaultPassCodeLayout,
                animator: Animator? = nil,
                tapHandler: @escaping TapHandler) {

        super.init(dataSource: dataSource,
                   viewSource: viewSource,
                   sizeSource: sizeSource,
                   layout: layout,
                   animator: animator,
                   tapHandler: tapHandler)
    }
}

public extension DefaultAppearance {

    enum PassCodeCollectionProvider {
        /// 10pt
        public static let lineSpacing: CGFloat = 10
        /// 10pt
        public static let interitemSpacing: CGFloat = 10
    }
}

private extension CGFloat {

    static let defaultLineSpacing = DefaultAppearance.PassCodeCollectionProvider.lineSpacing
    static let defaultInteritemSpacing = DefaultAppearance.PassCodeCollectionProvider.interitemSpacing
}

public extension PassCodeFitParentSizeSource {

    static var defaultPasscodeSizeSource: PassCodeFitParentSizeSource {
        return PassCodeFitParentSizeSource(lineSpacing: .defaultLineSpacing,
                                           interitemSpacing: .defaultInteritemSpacing)
    }
}

public extension Layout {

    static var defaultPassCodeLayout: Layout {
        return FlowLayout(lineSpacing: .defaultLineSpacing,
                          interitemSpacing: .defaultInteritemSpacing,
                          justifyContent: .center,
                          alignItems: .center,
                          alignContent: .center)
    }

    static var defaultLeftAlignedPassCodeLayout: Layout {
        return FlowLayout(lineSpacing: .defaultLineSpacing,
                          interitemSpacing: .defaultInteritemSpacing,
                          justifyContent: .start,
                          alignItems: .center,
                          alignContent: .center)
    }

    static var defaultRightAlignedPassCodeLayout: Layout {
        return FlowLayout(lineSpacing: .defaultLineSpacing,
                          interitemSpacing: .defaultInteritemSpacing,
                          justifyContent: .end,
                          alignItems: .center,
                          alignContent: .center)
    }
}
