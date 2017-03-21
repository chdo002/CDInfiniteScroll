

import UIKit
import yw_Extension

/* - - - - -  */
@objc
public protocol CDInfiniteScrollDelegate: NSObjectProtocol {
    
    // 子视图数量
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int
    
    // itme的宽度
    func itemWidthOfItems(in scrollView: CDInfiniteScroll) -> CGFloat
    
    // 所有item的视图
    func itemViewsForScrollView(_ scrollView: CDInfiniteScroll) -> [UIView]
}

open class CDInfiniteScroll: UIView {

    private(set) var scrollView: UIScrollView!
    
    subscript(index: Int) -> Any? {
        return nil
    }
    
    weak var delegate: CDInfiniteScrollDelegate? {
        didSet{
            self.setUpContent()
        }
    }
    
    // MARK:- ****************************************inner***********************************************
    
    var imageStore = [UIView]() // 5 * images
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.clipsToBounds = true
        self.scrollView.isPagingEnabled = true
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }
    
    func setUpContent(){
        
        guard let itemW = self.delegate?.itemWidthOfItems(in: self) else { return }
        guard let itemCount =  self.delegate?.numberOfItems(in: self) else { return }
        
        let sigleW = itemW * CGFloat(itemCount) // all view width combine
        let itemSize = CGSize(width: itemW, height: self.frame.height)
        
        
        
        GCD.asy {
            
            if let vies = self.delegate?.itemViewsForScrollView(self) {
                guard vies.count == itemCount else { return }
                
                // 首先将试图展示出来
                self.scrollView.contentSize = CGSize(width: CGFloat(itemCount * 5) * itemW, height: 0)
                GCD.main {
                    for (i, vie) in vies.enumerated() {
                        let itemx = CGFloat(i) * itemW + sigleW * 2
                        let rect = CGRect(origin: CGPoint(x: itemx, y: 0), size: itemSize)
                        vie.frame = rect
                        self.scrollView.addSubview(vie)
                    }
                }
                
                // 两侧视图
                var leftSection  = [UIView]()
                var rightSection = [UIView]()
                for (i, vie) in vies.enumerated() {
                    
                    let leftView    = UIImageView(image: vie.snapShot())
                    leftView.frame  = CGRect(origin: CGPoint(x:CGFloat(i) * itemW, y:0), size: itemSize)
                    leftSection.append(leftView)
                    
                    let rightView   = UIImageView(image: vie.snapShot())
                    rightView.frame = CGRect(origin: CGPoint(x:CGFloat(i) * itemW + sigleW * 3, y:0), size: itemSize)
                    rightSection.append(rightView)
                    
                    GCD.main {
                        self.scrollView.addSubview(leftView)
                        self.scrollView.addSubview(rightView)
                    }
                }
                
                self.imageStore = leftSection + vies + rightSection
            }
        }
        
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
