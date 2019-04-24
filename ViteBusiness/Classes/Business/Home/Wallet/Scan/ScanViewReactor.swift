//
//  ScanViewReactor.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/17.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift
import AVFoundation
import Alamofire

final class ScanViewReactor: Reactor {

    enum Action {
        case scanQRCode(AVMetadataObject?)
        case pickeImage(UIImage?)
    }

    enum Mutation {
        case processAVMetadata(AVMetadataObject?)
        case processImage(UIImage?)
    }

    struct State {
        var resultString: String?
        var toastMessage: String?
    }

    var initialState: State

    init() {
        self.initialState = State(
            resultString: nil,
            toastMessage: nil)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .pickeImage(pickedImage):
            return Observable.just(Mutation.processImage(pickedImage))
        case let .scanQRCode(metadataObject):
            return Observable.just(Mutation.processAVMetadata(metadataObject))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.toastMessage = nil
        switch mutation {
        case let .processImage(pickedImage):
            (newState.resultString, newState.toastMessage) = self.processImage(pickedImage)
        case let .processAVMetadata(metadata):
            newState.resultString = self.processAVMetadata(metadata)
        }
        return newState
    }

    func processImage(_ image: UIImage?) -> (resultString: String?, toastString: String?) {
        var resultString: String?
        var toastString: String? = R.string.localizable.scanPageQccodeNotFound()

        guard let image = image, let ciImage = CIImage.init(image: image) else {
            return (resultString, toastString)
        }
        var options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let context = CIContext()
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }

        guard let features = qrDetector?.features(in: ciImage, options: options), !features.isEmpty else {
            return (resultString, toastString)
        }
        for case let row as CIQRCodeFeature in features {
            resultString = row.messageString
        }
        if resultString != nil {
            toastString = nil
        }
        return (resultString, toastString)
    }

    func processAVMetadata(_ metadataObject: AVMetadataObject?) -> String? {
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return nil }
        return readableObject.stringValue
    }

}
