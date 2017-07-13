//
//  ViewController.swift
//  LXQRcode
//
//  Created by 唐小兵 on 2017/7/13.
//  Copyright © 2017年 liuxinxiaoyue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func scanQR(_ sender: Any) {
        let qrCodeVC = LXQRCodeController()
        self.navigationController?.pushViewController(qrCodeVC, animated: true)
    }
    @IBAction func createQR(_ sender: Any) {
        let generateVC = LXCreateQRCodeController()
        self.navigationController?.pushViewController(generateVC, animated: true)
    }
    @IBAction func read(_ sender: Any) {
        let img = UIImage(named: "scan")
        if let img = img {
            self.scanImage(img)
        }
    }
    
    private func scanImage(_ img: UIImage) {
        //二维码读取
        let ciImage = CIImage(image:img)
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        guard ciImage != nil else {
            return
        }
        let features=detector?.features(in: ciImage!)
        //遍历所有的二维码，并框出
        for feature in features as! [CIQRCodeFeature] {
            print(feature.messageString ?? "")
        }
    }
}

