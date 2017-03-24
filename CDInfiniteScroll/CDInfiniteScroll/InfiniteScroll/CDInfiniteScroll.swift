

import UIKit


/* - - - - -  */


/*
 若发现有布局问题，请检查viewcontroller的automaticallyAdjustsScrollViewInsets属性
 */
@objc
public protocol CDInfiniteScrollDelegate: NSObjectProtocol {
    
    // 子视图数量
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int
    
    // itme的宽度
    func itemWidthOfItems(in scrollView: CDInfiniteScroll) -> CGFloat
    
    // 所有item的视图
    func itemViewsForScrollView(_ scrollView: CDInfiniteScroll) -> [UIView]
    
    //
    @objc optional func scrollViewItemsWillSelect(_ scrollView: CDInfiniteScroll)
    
    @objc optional func scrollViewItemsDidSelect(_ scrollView: CDInfiniteScroll, at index: Int)
}

//enum InfiniteScolStyle {
//    case scrollFlat
//    case scrollScale(CGFloat, CGFloat)
//}

open class CDInfiniteScroll: UIScrollView, UIScrollViewDelegate{
    
//    var scrollStyle: InfiniteScolStyle = .scrollFlat
    
    public var scale:      CGFloat = 1 {
        didSet {
            self.scaleAnimate()
        }
    }
    public var scaleAlpha: CGFloat = 1 {
        didSet {
            self.scaleAnimate()
        }
    }
    
    public weak var scroDelegate: CDInfiniteScrollDelegate? {
        didSet{
            self.reSet()
            self.setUpContent()
        }
    }
  
    public var currentViewIndex = 0
    
    // MARK:- ****************************************inner***********************************************
    
    private(set) var itemW: CGFloat = 0      // 单个视图宽度
    private(set) var itemSize = CGSize.zero  // 单个视图体积
    private(set) var sigleW: CGFloat = 0     // 单个contentSize宽度
    private(set) var itemCount: Int = 0      // 视图数量
    private(set) var viewStore = [UIView]()  // 所有视图
    private(set) var snapping = false        // 是否在自动对齐中
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        isPagingEnabled = false
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        self.delegate = self
    }
   
    private func reSet(){
        self.viewStore.removeAll()
        self.snapping = false
        self.currentViewIndex = 0
        
    }
    
    private func setUpContent(){
        
        // 视图宽度
        guard let itemW = self.scroDelegate?.itemWidthOfItems(in: self) else { return }
        self.itemW = itemW

        // 单个scroll中的视图个数
        guard let itemCount =  self.scroDelegate?.numberOfItems(in: self) else { return }
        self.itemCount = itemCount
        
        // 单个scroll宽度
        self.sigleW = itemW * CGFloat(itemCount) // all view width combine
        
        self.itemSize = CGSize(width: itemW, height: self.frame.height)
        
        // 单个scroll中的视图
        if let centerViews = self.scroDelegate?.itemViewsForScrollView(self) {
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

    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scaleAnimate()
    }
    
    func scaleAnimate(){
        //        var scale: CGFloat = 1
        //        var itemAlp:   CGFloat = 1
        //        switch self.scrollStyle {
        //        case .scrollFlat:
        //            scale = 1
        //        case .scrollScale(let sc, let alp):
        //            if sc  >= 0.5 && sc  <= 1 { scale   = sc }
        //            if alp >= 0.2 && alp <= 1 { itemAlp = alp }
        //        }
        //
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
                    targetView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                    targetView.alpha = self.scaleAlpha
                })
            }
        }
        
        if self.isDragging {
            self.scroDelegate?.scrollViewItemsWillSelect?(self)
        }
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
                self.scroDelegate?.scrollViewItemsDidSelect?(self, at: self.currentViewIndex)
            })
        } else {
            self.snapping = false
            self.scroDelegate?.scrollViewItemsDidSelect?(self, at: self.currentViewIndex)
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


fileprivate extension UIView {
    fileprivate func snapShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
}
