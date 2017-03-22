
//  ViewController.swift
//  CDInfiniteScroll
//
//  Created by chdo on 2017/3/17.
//  Copyright © 2017年 yw. All rights reserved.
//

import UIKit

import yw_Extension




class ViewController: UIViewController, CDInfiniteScrollDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr = [#imageLiteral(resourceName: "padPic"),#imageLiteral(resourceName: "redpic"),#imageLiteral(resourceName: "redpic"),#imageLiteral(resourceName: "redpic"),#imageLiteral(resourceName: "watchPic")]
        
        for img in arr {
            let vvv = UIImageView(image: img)
            vvv.contentMode = .scaleAspectFit
            self.arr.append(vvv)
        }
        
        scroll = CDInfiniteScroll(frame: CGRect(origin: CGPoint(x:0, y: 100),
                                                     size: CGSize(width: screenW, height: 80)))
        scroll.dataSouce = self
        self.view.addSubview(scroll)
        self.view.backgroundColor = UIColor.cyan
    }
    var scroll: CDInfiniteScroll!
    
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int {
        return arr.count
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.scroll.testFunc()
    }
    
    // itme的宽度
    func itemWidthOfItems(in scrollView: CDInfiniteScroll) -> CGFloat {
        return 80
    }
    
    var arr = [UIImageView]()
    // 所有item的视图
    func itemViewsForScrollView(_ scrollView: CDInfiniteScroll) -> [UIView]{
        return arr
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
}
