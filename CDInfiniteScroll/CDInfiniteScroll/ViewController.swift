//
//  ViewController.swift
//  CDInfiniteScroll
//
//  Created by chdo on 2017/3/17.
//  Copyright © 2017年 yw. All rights reserved.
//

import UIKit

import yw_Extension




class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let scrol = CDInfiniteScroll(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 20)))
        self.view.addSubview(scrol)
        
        
        let lab = UILabel()
        lab.frame = CGRect(origin: CGPoint(x: 50, y: 100), size: CGSize(width: 200, height: 200))
        
        self.view.addSubview(lab)
        
        lab.font = UIFont.winnie(size: 15)
        lab.text = "123123"
        
        
        
    }
    
    var imgV = UIImageView(image: #imageLiteral(resourceName: "img"))
    

    override func viewDidAppear(_ animated: Bool) {
        
        

    }
    
    func numberOfItems(in scrollView: CDInfiniteScroll) -> Int {
        return 12
    }
    
    func scrollView(_ scrollView: CDInfiniteScroll, viewForRow row: Int) -> UIView {
        return UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
