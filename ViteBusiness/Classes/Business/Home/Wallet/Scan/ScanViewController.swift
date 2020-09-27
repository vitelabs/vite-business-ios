//
//  ScanViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import AVFoundation
import Then
import SnapKit

import ReactorKit
import RxSwift
import RxCocoa

extension Reactive where Base: ScanViewController {
    var result: Observable<String> {
        return base.result.asObservable().share()
    }
}

class ScanViewController: BaseViewController, View {

    private var pickingImage = false

    fileprivate var result: PublishSubject<String> = PublishSubject<String>()

    var disposeBag = DisposeBag()

    private let scanViewWidth: CGFloat = 262.0
    private let scanViewCenterYOffset: CGFloat = 70.0

    private let sessionQueue = DispatchQueue(label: "cameraManagerQueue")
    private let captureSession = AVCaptureSession()
    private let captureMetadataOutput = AVCaptureMetadataOutput()

    private let imagePicker = UIImagePickerController().then { (imagePicker) in
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVComponents()
        setupUIComponents()
        self.reactor = ScanViewReactor.init()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startCaptureSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopCaptureSession()
        if !pickingImage {
            self.result.onCompleted()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupAVComponents() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.backgroundColor = UIColor(netHex: 0x24272B).cgColor
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        self.sessionQueue.async {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                self.captureSession.addInput(input)
                self.captureSession.addOutput(self.captureMetadataOutput)
                self.captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                let scanRect = CGRect(x: (videoPreviewLayer.bounds.size.width - self.scanViewWidth)/2,
                                      y: (videoPreviewLayer.bounds.size.height - kNavibarH - self.scanViewWidth)/2 - self.scanViewCenterYOffset,
                                      width: self.scanViewWidth,
                                      height: self.scanViewWidth)
                let rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
                self.captureMetadataOutput.rectOfInterest = rectOfInterest
            } catch {
                plog(level: .severe, log: "Init AVCaptureDeviceInput error")
            }
        }
    }

    private func setupUIComponents() {
        navigationItem.title = R.string.localizable.scanPageTitle()
        navigationBarStyle = .custom(tintColor: UIColor.white, backgroundColor: UIColor(netHex: 0x24272B))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_photo_black(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.pickeImage(_:)))

        let clearView = UIView().then {
            $0.backgroundColor = UIColor.clear
            $0.layer.borderColor = UIColor(netHex: 0x0079df).cgColor
            $0.layer.borderWidth = 2
        }

        let topBackgroundView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x24272B).withAlphaComponent(0.8)
        }
        let leftBackgroundView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x24272B).withAlphaComponent(0.8)
        }
        let bottomBackgroundView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x24272B).withAlphaComponent(0.8)
        }
        let rightBackgroundView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x24272B).withAlphaComponent(0.8)
        }

        let flashButton = UIButton().then {
            $0.setImage(R.image.icon_button_light(), for: .normal)
            $0.setImage(R.image.icon_button_light()?.highlighted, for: .highlighted)

            guard let device = AVCaptureDevice.default(for: .video) else { return }
            if !device.hasTorch || !device.isTorchAvailable {
                $0.isHidden = true
            }
        }

        view.addSubview(clearView)
        view.addSubview(topBackgroundView)
        view.addSubview(bottomBackgroundView)
        view.addSubview(leftBackgroundView)
        view.addSubview(rightBackgroundView)
        view.addSubview(flashButton)

        clearView.snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.centerY.equalTo(view).offset(-scanViewCenterYOffset)
            m.size.equalTo(CGSize(width: scanViewWidth, height: scanViewWidth))
        }

        topBackgroundView.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(view)
            m.bottom.equalTo(clearView.snp.top)
        }

        bottomBackgroundView.snp.makeConstraints { (m) in
            m.bottom.left.right.equalTo(view)
            m.top.equalTo(clearView.snp.bottom)
        }

        leftBackgroundView.snp.makeConstraints { (m) in
            m.top.equalTo(topBackgroundView.snp.bottom)
            m.bottom.equalTo(bottomBackgroundView.snp.top)
            m.left.equalTo(view)
            m.right.equalTo(clearView.snp.left)
        }

        rightBackgroundView.snp.makeConstraints { (m) in
            m.top.equalTo(topBackgroundView.snp.bottom)
            m.bottom.equalTo(bottomBackgroundView.snp.top)
            m.left.equalTo(clearView.snp.right)
            m.right.equalTo(view)
        }

        flashButton.snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(clearView.snp.bottom).offset(40)
        }

        flashButton.addTarget(self, action: #selector(switchFlash(_:)), for: .touchUpInside)
    }

    @objc private func pickeImage(_ button: UIBarButtonItem) {
        self.pickingImage = true
        present(imagePicker, animated: true) {}
    }

    @objc private func switchFlash(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch && device.isTorchAvailable {
            try? device.lockForConfiguration()
            if device.torchMode == .off {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        }
    }

    func startCaptureSession() {
        self.sessionQueue.async {
            if self.captureSession.isRunning == false {
                self.captureSession.startRunning()
            }
        }
    }

    func stopCaptureSession() {
        self.sessionQueue.async {
            if self.captureSession.isRunning == true {
                self.captureSession.stopRunning()
            }
        }
    }

    func bind(reactor: ScanViewReactor) {
        imagePicker.rx.didFinishPickingMediaWithInfo
            .map { ScanViewReactor.Action.pickeImage($0[UIImagePickerController.InfoKey.originalImage] as? UIImage) }
            .bind { action in
                self.imagePicker.dismiss(animated: true, completion: {
                    reactor.action.onNext(action)
                })
            }
            .disposed(by: disposeBag)

        captureMetadataOutput.rx.metadataOutput
            .map { ScanViewReactor.Action.scanQRCode($0.first) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.toastMessage }
            .filterNil()
            .subscribe(onNext: { [unowned self] in
                self.showToast(string: $0)
            })
            .disposed(by: disposeBag)


        reactor.state
            .map { $0.resultString }
            .filterNil()
            .bind {[weak self] result in
                self?.stopCaptureSession()
                self?.result.onNext(result)
            }
            .disposed(by: disposeBag)
    }

    func showToast(string: String) {
        Toast.show(string)
        self.stopCaptureSession()
        GCD.delay(2, task: { [weak self] in
            self?.startCaptureSession()
        })
    }

    func showAlertMessage(_ alertMessage: String) {
        self.stopCaptureSession()
        let alertController = UIAlertController.init()
        let action = UIAlertAction.init(title: R.string.localizable.finish(), style: .default) { [weak self] (_) in
            self?.startCaptureSession()
        }
        alertController.addAction(action)
        alertController.title = alertMessage
        self.present(alertController, animated: true, completion: nil)
    }
}
