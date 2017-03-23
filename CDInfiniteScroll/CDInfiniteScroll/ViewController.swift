
import UIKit

class ViewController: UIViewController, CDInfiniteScrollDelegate {

    
    var arr = [UIImageView]()
    var scroll: CDInfiniteScroll!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let arr = [#imageLiteral(resourceName: "Artboard"),#imageLiteral(resourceName: "Artboard Copy"), #imageLiteral(resourceName: "Artboard Copy 2"), #imageLiteral(resourceName: "Artboard Copy 3"), #imageLiteral(resourceName: "Artboard Copy 4"), #imageLiteral(resourceName: "Artboard Copy 5"), #imageLiteral(resourceName: "Artboard Copy 6"), #imageLiteral(resourceName: "Artboard Copy 7")]
        
        for img in arr {
            let vvv = UIImageView(image: img)
            vvv.contentMode = .scaleAspectFit
            self.arr.append(vvv)
        }
        
        scroll = CDInfiniteScroll(frame: CGRect(origin: CGPoint(x:0, y: 100),
                                                  size: CGSize(width: self.view.frame.width, height: 160)))
//        scroll.scrollStyle = .scrollScale(0.7, 0.3)
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
