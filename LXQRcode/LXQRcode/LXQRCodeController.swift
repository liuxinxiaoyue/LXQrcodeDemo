//
//  LXQRCodeController.swift
//  LXQRCode
//
//  Created by 唐小兵 on 2017/3/20.
//  Copyright © 2017年 liuxinxiaoyue. All rights reserved.
//

import UIKit
import AVFoundation

private let scanWH = 220.0
private let screenWidth = Double(UIScreen.main.bounds.width)
private let screenHeight = Double(UIScreen.main.bounds.height)
private let left = (screenWidth - scanWH) / 2
private let top = (screenHeight - scanWH) / 2
private let cropRect = CGRect(x: left, y: top, width: scanWH, height: scanWH)

class LXQRCodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var device: AVCaptureDevice!
    private var input: AVCaptureDeviceInput!
    private var output: AVCaptureMetadataOutput!
    private var session: AVCaptureSession!
    private var preview: AVCaptureVideoPreviewLayer!
    private var lineImgView: UIImageView?
    private var timer: Timer?
    private var toDown: Bool = true

    init() {
        super.init(nibName: nil, bundle: nil)
        self.stepDefault()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.stepDefault()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.stepDefault()
    }
    
    private func stepDefault() {
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        output = AVCaptureMetadataOutput()
        //AVCapture输出的图片大小都是横着的，而iPhone的屏幕是竖着的
        output.rectOfInterest = CGRect(x: top/screenHeight, y: left/screenWidth, width: scanWH/screenHeight, height: scanWH/screenWidth)
        
        session = AVCaptureSession()
        //
        session.sessionPreset = AVCaptureSessionPresetHigh
        // 连接输入输出
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        //扫描画面
        preview = AVCaptureVideoPreviewLayer(session: session)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        self.configView()
        // 判断权限
        let mediaType = AVMediaTypeVideo
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        if authStatus != .authorized {
            let alertVC = UIAlertController(title: nil, message: "没有使用相机的权限", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            let setAction = UIAlertAction(title: "设置", style: .default, handler: { [unowned self] (action) in
                self.goSetting()
            })
            alertVC.addAction(sureAction)
            alertVC.addAction(setAction)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 设置条码类型
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        session.startRunning()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(lineAnimation), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("dinit...")
    }
    
    private func configView() {
        
        let cropLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(cropRect)
        path.addRect(view.bounds)
        cropLayer.fillRule = kCAFillRuleEvenOdd
        cropLayer.path = path
        cropLayer.fillColor = UIColor.black.cgColor
        cropLayer.opacity = 0.6
        view.layer.addSublayer(cropLayer)
        
        let imgView = UIImageView(frame: cropRect)
        imgView.image = UIImage.init(named: "bord")
        view.addSubview(imgView)
        
        let rect = CGRect(x: cropRect.minX, y: cropRect.minY + 5, width: cropRect.width, height: 2)
        let lineImgView = UIImageView(frame: rect)
        lineImgView.image = UIImage(named: "line")
        view.addSubview(lineImgView)
        self.lineImgView = lineImgView
        
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        preview.frame = view.layer.bounds
        view.layer.insertSublayer(preview, at: 0)
    }
    
    //MARK:- AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var stringValue: String? = nil
        if metadataObjects.count > 0 {
            // 停止扫描
            session.stopRunning()
            timer?.invalidate()
            let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            stringValue = metadataObject?.stringValue
        }
        if let str = stringValue {
            print("string value is \(str)")
        }
    }
    
    @objc private func lineAnimation() {
        guard lineImgView != nil else {
            return
        }
        
        var frame = lineImgView!.frame
        if toDown {
            frame.origin.y += 2
            if frame.maxY >= cropRect.maxY - 10 {
                frame.origin.y -= 4
                toDown = false
            }
        } else {
            frame.origin.y -= 2
            if frame.minY <= cropRect.minY + 10 {
                frame.origin.y += 4
                toDown = true
            }
        }
        lineImgView?.frame = frame
    }
    
    private func goSetting() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: ["":""], completionHandler: { (succ) in
                    
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
