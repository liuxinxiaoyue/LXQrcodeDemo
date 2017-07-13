//
//  LXCreateQRCodeController.swift
//  LXQRCode
//
//  Created by 唐小兵 on 2017/3/20.
//  Copyright © 2017年 liuxinxiaoyue. All rights reserved.
//

import UIKit

class LXCreateQRCodeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.white
        
        let imgView = UIImageView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        let img = self .qrCodeWithString("www.baidu.com", logImg: nil)
        imgView.image = img
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func qrCodeWithString(_ str: String, logImg: String?) -> UIImage? {
        let content = str.data(using: .utf8)
        //创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(content, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter?.outputImage
        
        // 创建一个颜色滤镜,黑白色
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        // 返回二维码image
        let codeImage = UIImage(ciImage: (colorFilter.outputImage!.applying(CGAffineTransform(scaleX: 5, y: 5))))
        
        // 中间一般放logo
        if let logImg = logImg, let iconImage = UIImage(named: logImg) {
            
            let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
            
            UIGraphicsBeginImageContext(rect.size)
            codeImage.draw(in: rect)
            let avatarSize = CGSize(width: rect.size.width*0.25, height: rect.size.height*0.25)
            
            let x = (rect.width - avatarSize.width) * 0.5
            let y = (rect.height - avatarSize.height) * 0.5
            iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return resultImage
        }
        return codeImage;
    }

}
