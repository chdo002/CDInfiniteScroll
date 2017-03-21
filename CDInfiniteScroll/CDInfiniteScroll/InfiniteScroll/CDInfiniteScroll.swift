

import UIKit

public protocol CDInfiniteScrollDelegate: NSObjectProtocol {
    
    // 子视图数量
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int
    
    // itme的宽度
    func itemWidthOfItems(in scrollView: CDInfiniteScroll) -> CGFloat
    
    // 每个item视图
    func scrollView(_ scrollView: CDInfiniteScroll, viewForRow row: Int) -> UIView
    
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
        
        
//        guard let itemW = self.delegate?.itemWidthOfItems(in: self) else {
//            
//            return
//        }
//        
//        guard let itemCount =  self.delegate?.numberOfItems(in: self) else {
//            
//            return
//        }
        
//        let sigleW = itemW * itemCount
        
//        for i in 0..<itemCount * 5 {
//            
//        }
        
     
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
