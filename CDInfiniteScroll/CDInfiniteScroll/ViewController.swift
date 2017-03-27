
import UIKit

class ViewController: UIViewController, CDInfiniteScrollDelegate {

    
    var arr = [UIImageView]()
    var scroll: CDInfiniteScroll!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let centerView = UIView(frame: CGRect(x: self.view.frame.width / 2 - 5, y: 95, width: 10, height: 5))
        centerView.backgroundColor = UIColor.black
        self.view.addSubview(centerView)
        
        let arr = [#imageLiteral(resourceName: "Artboard"),#imageLiteral(resourceName: "Artboard Copy"), #imageLiteral(resourceName: "Artboard Copy 2"), #imageLiteral(resourceName: "Artboard Copy 3"), #imageLiteral(resourceName: "Artboard Copy 4"), #imageLiteral(resourceName: "Artboard Copy 5"), #imageLiteral(resourceName: "Artboard Copy 6"), #imageLiteral(resourceName: "Artboard Copy 7")]        
//        let arr = [#imageLiteral(resourceName: "Artboard"),#imageLiteral(resourceName: "Artboard Copy"), #imageLiteral(resourceName: "Artboard Copy 5")]
        for img in arr {
            let vvv = UIImageView(image: img)
            vvv.contentMode = .scaleAspectFit
            self.arr.append(vvv)
        }

        let rect = CGRect(origin: CGPoint(x:0, y: 100), size: CGSize(width: self.view.frame.width, height: 160))
//        scroll = CDInfiniteScroll(frame: rect, isAlignmentCenter: false)
        scroll = CDInfiniteScroll(frame: rect)
        scroll.scale      = 0.7
        scroll.scaleAlpha = 0.3
        scroll.scroDelegate = self
        
        self.view.addSubview(scroll)
        
        self.view.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func scaleAction(_ sender: UISlider) {
        scroll.scale = CGFloat(sender.value)
    }
    
    @IBAction func alphaAction(_ sender: UISlider) {
        scroll.scaleAlpha = CGFloat(sender.value)
    }
    
    @IBAction func previousPic(_ sender: Any) {
        let previousIndex = self.scroll.currentViewIndex - 1
        if scroll.currentViewIndex <= 0 {
            self.scroll.setCurrentIndex(arr.count - 1)
        } else{
            self.scroll.setCurrentIndex(previousIndex)
        }
    }
  
    @IBAction func nextPic(_ sender: Any) {
        let nextIndex = self.scroll.currentViewIndex + 1
        if scroll.currentViewIndex >= self.arr.count - 1 {
            self.scroll.setCurrentIndex(0)
        } else{
            self.scroll.setCurrentIndex(nextIndex)
        }
    }
    
    // MARK:- ****************************************CDInfiniteScrollDelegate***********************************************
    
    // item数量
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int {
        return arr.count
    }
    // itme的宽度
    func itemWidthOfItems(in scrollView: CDInfiniteScroll) -> CGFloat {
        return 80
    }
    
    func itemViewsForScrollView(_ scrollView: CDInfiniteScroll) -> [UIView]{
        return arr
    }
    
//  optional
    func scrollViewItemsDidSelect(_ scrollView: CDInfiniteScroll, at index: Int) {
        print("scrollView select ar index \(index)")
    }
}
