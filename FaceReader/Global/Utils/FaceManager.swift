//
//  FaceManager.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

import Alamofire
import Foundation

final class FaceManager {
    
    static let shared = FaceManager()
    
    static var leftEye: [CGPoint]? = nil
    static var rightEye: [CGPoint]? = nil
    static var leftEyebrow: [CGPoint]? = nil
    static var rightEyebrow: [CGPoint]? = nil
    static var nose: [CGPoint]? = nil
    static var outerLips: [CGPoint]? = nil
    static var innerLips: [CGPoint]? = nil
    static var faceContour: [CGPoint]? = nil
    
    static var faceImage: UIImage? = nil
    static var cartoonImage: UIImage? = nil
    
    static var totalScore: Int = 0
    static var grade: Int = 0
    
    func setValues() {
        guard let leftEyebrow = FaceManager.leftEyebrow else { return }
        guard let rightEye = FaceManager.rightEye else { return }
        guard let leftEye = FaceManager.leftEye else { return }
        guard let nose = FaceManager.nose else { return }
        guard let outerLips = FaceManager.outerLips else { return }
        guard let faceContour = FaceManager.faceContour else { return }
        
        // eye
        let eyeDistance = (rightEye[3].x - leftEye[3].x) as Double
        let eyeWidth = (leftEye[3].x - leftEye[0].x) as Double
        
        // nose
        let noseWidth = (nose[5].x - nose[3].x) as Double
        let noseHeight = (nose[4].y - nose[0].y) as Double
        
        // lips
        let lipsWidth = (outerLips[7].x - outerLips[13].x) as Double
        let lipsHeight = (outerLips[10].y - outerLips[4].y) as Double
        
        // face
        let faceFirst = (nose[4].y - leftEyebrow[3].y) as Double
        let faceSecond = (faceContour[8].y - nose[4].y) as Double
        
        // ratio
        let eyeRatio = eyeDistance / eyeWidth // 1에 가까워야함 -> 1.1
        let noseRatio = noseWidth / noseHeight // 0.64에 가까워야함 -> 0.6
        let lipsRatio = lipsWidth / lipsHeight // 3에 가까워야함 -> 2.6
        let faceRatio = faceFirst / faceSecond // 1에 가까워야함 -> 1.1
        
        // score
        let eyeRatioScore = Int(abs(eyeRatio - 1.1) * 20000) * 1000
        let noseRatioScore = Int(abs(noseRatio - 0.6) * 20000) * 1000
        let lipsRatioScore = Int(abs(lipsRatio - 2.6) * 10000) * 1000
        let faceRatioScore = Int(abs(faceRatio - 1.1) * 20000) * 1000
        
        FaceManager.totalScore = eyeRatioScore + noseRatioScore + lipsRatioScore + faceRatioScore
        
        if FaceManager.totalScore < 10000000 {
            FaceManager.grade = 0
        } else if FaceManager.totalScore < 15000000 {
            FaceManager.grade = 1
        } else if FaceManager.totalScore < 20000000 {
            FaceManager.grade = 2
        } else if FaceManager.totalScore < 30000000 {
            FaceManager.grade = 3
        } else {
            FaceManager.grade = 4
        }
    }
    
    func postImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let URL = "https://master-white-box-cartoonization-psi1104.endpoint.ainize.ai/predict"
        let header : HTTPHeaders = [
            "accept": "image/jpg",
            "Content-Type" : "multipart/form-data"
        ]
        let parameters: [String : Any] = [
            "file_type" : "image"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = FaceManager.faceImage?.pngData() {
                multipartFormData.append(image, withName: "source", fileName: "\(image).png", mimeType: "image/png")
            }
        }, to: URL, usingThreshold: UInt64.init(), method: .post, headers: header).response { response in
            switch response.result {
            case .success(let value):
                guard let cartoonImage = UIImage(data: value!) else {
                    completion(.success(FaceManager.faceImage!))
                    return
                }
                completion(.success(cartoonImage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private init() { }
}

let gradeData: [[String: String]] = [
    [
        "grade": "낭(狼)",
        "info": "위험인자가 될 집단의 출현"
    ],
    [
        "grade": "호(虎)",
        "info": "불특정 다수의 생명의 위기"
    ],
    [
        "grade": "귀(鬼)",
        "info": "도시 전체의 기능정지 및 괴멸 위기"
    ],
    [
        "grade": "용(龍)",
        "info": "도시 여러개가 괴멸 당할 위기"
    ],
    [
        "grade": "신(神)",
        "info": "인류멸망의 위기"
    ],
]
