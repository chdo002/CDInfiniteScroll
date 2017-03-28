

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

open class CDInfiniteScroll: UIScrollView, UIScrollViewDelegate{
    
    
    /*
     *  大小变形
     */
    public var scale:      CGFloat = 1 {
        didSet {
            if willinfinite || isAlignmentCenter {
                self.scaleAnimate()
            } else {
                self.fixItemAnimate(self.currentViewIndex)
            }
        }
    }
    
    /*
     *  透明变形
     */
    
    public var scaleAlpha: CGFloat = 1 {
        didSet {
            if willinfinite || isAlignmentCenter {
                self.scaleAnimate()
            } else {
                self.fixItemAnimate(self.currentViewIndex)
            }
        }
    }
    
    
    public weak var scroDelegate: CDInfiniteScrollDelegate? {
        didSet{
            self.reSet()
            self.setUpContent()
        }
    }
    
    private(set) var currentViewIndex = 0
    
    // MARK:- ****************************************public***********************************************
    
    public func setCurrentIndex(_ index: Int){
        if self.willinfinite {
            
            
            let offsetX = CGFloat(index) * itemW + sigleW * 2 - self.frame.width * 0.5 + itemW * 0.5
            
            self.contentOffset = CGPoint(x: offsetX, y: 0)
            
            self.currentViewIndex = index
            
        } else {
            
            if isAlignmentCenter {
                let offsetx = CGFloat(index) * itemW
                self.currentViewIndex = index
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.contentOffset = CGPoint(x: offsetx, y: 0)
                }, completion: { (_) in
                    self.snapping = false
                })
                
            } else {
                self.fixItemAnimate(index)
            }
        }
    }
    
    // MARK:- ****************************************inner***********************************************
    
    private(set) var itemW: CGFloat = 0      // 单个视图宽度
    private(set) var itemSize = CGSize.zero  // 单个视图体积
    private(set) var sigleW: CGFloat = 0     // 单个contentSize宽度
    private(set) var itemCount: Int = 0      // 视图数量
    private(set) var viewStore = [UIView]()  // 所有视图
    private(set) var snapping = false        // 是否在自动对齐中
    
    private(set) var isAlignmentCenter: Bool = true
    
    private(set) var leftPlaceholder: UIView = {
        let vv = UIView()
        vv.backgroundColor = UIColor.clear
        return vv
    }()
    
    private(set) var rightPlaceholder: UIView = {
        let vv = UIView()
        vv.backgroundColor = UIColor.clear
        return vv
    }()
    
    private(set) var willinfinite = true
    
    /*
     * isAlignmentCenter: 滚动时，当前视图是否会在中央
     */
    public init(frame: CGRect, isAlignmentCenter: Bool = true){
        super.init(frame: frame)
        
        self.isAlignmentCenter = isAlignmentCenter
        self.clipsToBounds = true
        self.isPagingEnabled = false
        self.backgroundColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        self.delegate = self
    }
    
    private func reSet(){
        // 清空视图中的items
        for vvv in self.viewStore {
            vvv.removeFromSuperview()
        }
        self.viewStore.removeAll()
        self.snapping = false
        self.currentViewIndex = 0
        self.willinfinite = true
    }
    
    private func setUpContent(){
        
        // 单个视图宽度
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
            
            if sigleW <= self.bounds.width {
                
                self.willinfinite = false
                
                // 中间对齐
                if isAlignmentCenter {
                    
                    let contentWidth = CGFloat(itemCount - 1) * itemW + frame.width
                    
                    self.contentSize = CGSize(width: contentWidth, height: 0)
                    
                    let baseX = (self.frame.width - itemW) * 0.5 //
                    for (i, vie) in centerViews.enumerated() {
                        let rect = CGRect(origin: CGPoint(x: baseX + CGFloat(i) * itemW, y: 0), size: self.itemSize)
                        vie.frame = rect
                        vie.clipsToBounds = true
                        self.addSubview(vie)
                    }
                    
                    self.leftPlaceholder.frame  = CGRect(origin: CGPoint.zero,
                                                         size: CGSize(width: baseX, height: self.frame.height))
                    self.addSubview(self.leftPlaceholder)
                    self.rightPlaceholder.frame = CGRect(origin: CGPoint(x: baseX + CGFloat(itemCount) * itemW, y: 0),
                                                         size: CGSize(width: baseX, height: self.frame.height))
                    self.addSubview(self.rightPlaceholder)
                    
                    self.viewStore = centerViews
                    self.fixItemAnimate(0)
                    self.scaleAnimate()
                } else {
                // items 固定位置
                    let baseX = (self.bounds.width - sigleW) * 0.5 //
                    self.contentSize = self.bounds.size
                    for (i, vie) in centerViews.enumerated() {
                        let rect = CGRect(origin: CGPoint(x: baseX + CGFloat(i) * itemW, y: 0), size: self.itemSize)
                        vie.frame = rect
                        vie.clipsToBounds = true
                        self.addSubview(vie)
                        let tap = UITapGestureRecognizer(target: self, action: #selector(tapItemGes(tap:)))
                        vie.addGestureRecognizer(tap)
                        vie.isUserInteractionEnabled = true
                        vie.tag = i
                    }
                    self.viewStore = centerViews
                    self.fixItemAnimate(0)
                }
            } else {
                
                self.willinfinite = true
                
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
                // set 偏移量
                let offSet = sigleW * 2 - self.frame.width * 0.5 + itemW * 0.5
                self.setContentOffset(CGPoint(x: offSet, y: 0), animated: false)
            }
        }
        
    }
    
    // MARK:- ****************************************监听滚动***********************************************
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scaleAnimate()
    }
    
    private func scaleAnimate(){
        
        if !self.willinfinite && !self.isAlignmentCenter {
            return
        }
        
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
    
    private func snapEmotion(){
        
        if willinfinite {
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
        } else {
            guard self.isAlignmentCenter else {
                return
            }
            self.snapping = true
            if self.contentOffset.x < 0 {
                self.snapping = false
                return
            } else {
                func test(_ abc: Int) -> Int{
                    if abc % 2 == 0 {
                        return abc / 2
                    } else {
                        return (abc + 1 ) / 2
                    }
                }
                self.currentViewIndex = test(Int(self.contentOffset.x) / Int(self.itemW * 0.5))
                let offsetx = CGFloat(currentViewIndex) * itemW

                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.contentOffset = CGPoint(x: offsetx, y: 0)
                }, completion: { (_) in
                    self.snapping = false
                    self.scroDelegate?.scrollViewItemsDidSelect?(self, at: self.currentViewIndex)
                })
            }
        }
        
    }
    
    
    // MARK:- **************************************** 当 isAlignmentCenter是false时***********************************************
    func tapItemGes(tap: UITapGestureRecognizer){
        self.fixItemAnimate(tap.view!.tag) { 
            self.scroDelegate?.scrollViewItemsDidSelect?(self, at: self.currentViewIndex)
        }
    }
    
    private func fixItemAnimate(_ index: Int, complete: (()-> Void)? = nil) {
        for (i, vie) in self.viewStore.enumerated() {
            if i == index {
                UIView.animate(withDuration: 0.2, animations: { 
                    vie.transform = CGAffineTransform(scaleX: 1, y: 1)
                    vie.alpha = 1
                }, completion: { (_) in
                    self.currentViewIndex = i
                    complete?()
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: { 
                    vie.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                    vie.alpha = self.scaleAlpha
                })
            }
        }
    }
    

    // MARK:- ****************************************doInfinite***********************************************
    override open func layoutSubviews() {
        super.layoutSubviews()
        doInfinite()
    }
    
    func doInfinite(){
        guard self.willinfinite else { return }
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


extension UIView {
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
