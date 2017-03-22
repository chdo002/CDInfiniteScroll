

import UIKit

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

open class CDInfiniteScroll: UIScrollView, UIScrollViewDelegate{


    private(set) var snapping = false
    
    weak var dataSouce: CDInfiniteScrollDelegate? {
        didSet{
            self.setUpContent()
        }
    }
    
    // MARK:- ****************************************inner***********************************************

    private(set) var itemW: CGFloat = 0      // 单个视图宽度
    private(set) var itemSize = CGSize.zero  // 单个视图体积
    private(set) var sigleW: CGFloat = 0     // 单个contentSize宽度
    private(set) var itemCount: Int = 0      // 视图数量
    private(set) var viewStore = [UIView]()  // 所有视图
    private(set) var currentViewIndex = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        isPagingEnabled = false
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = UIColor.green
        self.delegate = self
    }
    
    func setUpContent(){
        
        // 视图宽度
        guard let itemW = self.dataSouce?.itemWidthOfItems(in: self) else { return }
        self.itemW = itemW

        // 单个scroll中的视图个数
        guard let itemCount =  self.dataSouce?.numberOfItems(in: self) else { return }
        self.itemCount = itemCount
        
        // 单个scroll宽度
        self.sigleW = itemW * CGFloat(itemCount) // all view width combine
        
        self.itemSize = CGSize(width: itemW, height: self.frame.height)
        
        // 单个scroll中的视图
        if let centerViews = self.dataSouce?.itemViewsForScrollView(self) {
            guard centerViews.count == itemCount else { return }
            
            self.contentSize = CGSize(width: sigleW * 5, height: 0)
            
            // 首先将中间的scroll试图展示出来
                for (i, vie) in centerViews.enumerated() {
                    let itemx = self.sigleW * 2 + CGFloat(i) * self.itemW
                    let rect = CGRect(origin: CGPoint(x: itemx, y: 0), size: self.itemSize)
                    vie.frame = rect
                    vie.clipsToBounds = true
                    self.addSubview(vie)
                }
            
            
            // 两侧视图
            func addSnapView(vie: UIView, rect: CGRect) -> UIView{
                let itemView = UIImageView(image: vie.snapShot())
                itemView.contentMode = .scaleAspectFit
                itemView.frame = rect
                itemView.clipsToBounds = true
                return itemView
            }
            
            var leftSection = [UIView]()
            for index in [0,1,3,4] { // section下标
                var sectionArr = [UIView]()
                for (i, vie) in centerViews.enumerated() {
                    let itemX = CGFloat(i) * itemW + sigleW * CGFloat(index)
                    let itemView = addSnapView(vie: vie, rect: CGRect(origin: CGPoint(x: itemX, y:0),
                                                                        size: itemSize))
                    sectionArr.append(itemView)
                    self.addSubview(itemView)
                }
                if index < 3 {
                    leftSection = leftSection + sectionArr
                } else {
                    self.viewStore = self.viewStore + sectionArr
                }
            }
            self.viewStore = leftSection + centerViews + self.viewStore
        }
        
        // set 偏移量
        let offSet = sigleW * 2 - self.frame.width * 0.5 + itemW * 0.5
        self.setContentOffset(CGPoint(x: offSet, y: 0), animated: false)
        for (index, viee) in self.viewStore.enumerated() {
            if index != itemCount * 2 {
                viee.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let left = self.contentOffset.x + self.frame.width * 0.5 - self.itemW * 0.5
        
        let right = left + self.itemW
        
        for targetView in self.viewStore {
            if targetView.center.x > left && targetView.center.x < right {

                UIView.animate(withDuration: 0.1, animations: {
                    targetView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    targetView.alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    targetView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    targetView.alpha = 0.8
                })
            }
        }
        
//        if centerView != nil {
//            let dx = abs(centerView.center.x - (left + self.itemW * 0.5))
//            let scale  = -0.005 * dx + 1
//            centerView.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !self.snapping && !decelerate {
            self.snapEmotion()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !snapping{
            self.snapEmotion()
        }
    }
    
    func snapEmotion(){
        self.snapping = true
        var centerView: UIView!
    
        let left = self.contentOffset.x + self.frame.width * 0.5 - self.itemW * 0.5

        let right = left + self.itemW
        
        
        for (i, targetView) in self.viewStore.enumerated() {
            if targetView.center.x > left && targetView.center.x < right {
                centerView = targetView
                self.currentViewIndex = i % itemCount
            }
        }
        
        if centerView != nil {
            let dX = self.contentOffset.x - (centerView.center.x - self.frame.width * 0.5)
            let newX = self.contentOffset.x - dX
            UIView.animate(withDuration: 0.1, animations: { 
                self.contentOffset = CGPoint(x: newX, y: 0)
                centerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (_) in
              self.snapping = false
            })
        } else {
            self.snapping = false
        }
        
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        doInfinite()
    }
    
    func doInfinite(){
        if self.contentOffset.x > 0 {
            if self.contentOffset.x <= sigleW * 0.5 {
                self.contentOffset = CGPoint(x: sigleW * 1.5, y: 0)
            } else if self.contentOffset.x >= sigleW * 3.5 {
                self.contentOffset = CGPoint(x: sigleW * 2.5, y: 0)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
