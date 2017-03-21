//
//  String_Extension.swift

//
//  Created by chdo on 3/26/15.
//  Copyright (c) 2015 Louding. All rights reserved.
//

import UIKit

extension String {
    
    // MD5的加密
    var md5: String! {
        return Exten.md5Str(self)
    }

    public var isPureEmpty: Bool {
        if isEmpty { return true }
        for c in self.characters {
            if c != " " {
                return false
            }
        }
        return true
    }
    
    
    public var UTF8length : Int {
        var len = 0
        for i in self.characters {
            if String(i).lengthOfBytes(using: String.Encoding.utf8) == 3 {
                len += 2
            }else{  // 1 , 4
                len += 1
            }
        }
        return len
    }
    
    public func subStringAt(indx: Int) -> String{
        var str = ""
        for i in self.characters {
            let tem = str + String(i)
            if tem.UTF8length >= indx {
                break
            } else {
                str = str + String(i)
            }
        }
        return str
    }
    
    public subscript (i: Int) -> String{
        return String(Array(self.characters)[i])
    }
    
    public func addPathCompent(path: String) -> String{
        return self + "/\(path)"
    }
    
    public func size(byfontsize size: CGFloat) -> CGSize{
        return (self as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: size)])
    }
    
    public func size(byFont font : UIFont) -> CGSize{
        return (self as NSString).size(attributes: [NSFontAttributeName: font])
    }
    
    // MARK:- *****************************QR  二维码*****************************
    /**
     生成QR  （iOS 8.0以上）
     */
    public func encodeQRImageWithContent(size: CGSize) -> UIImage? {
        
        var codeImage: UIImage?
        let stringData = self.data(using: String.Encoding.utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("M", forKey: "inputCorrectionLevel")
        let colorFilter = CIFilter(name: "CIFalseColor", withInputParameters: [
            "inputImage": qrFilter!.outputImage!,
            "inputColor0": CIColor(cgColor: UIColor.black.cgColor),
            "inputColor1": CIColor(cgColor: UIColor.white.cgColor)
        ])
        let qrImage = colorFilter?.outputImage
        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: qrImage!.extent)
        
        UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = CGInterpolationQuality.none
        context!.scaleBy(x: 1, y: -1)
        context?.draw(cgImage!, in: context!.boundingBoxOfClipPath)
        codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return codeImage
    }

}
