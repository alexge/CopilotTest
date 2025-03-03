//
//  ImageService.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import AlamofireImage
import UIKit

final class ImageService {
    let session: URLSession
    let imageCache: AutoPurgingImageCache
    
    init(session: URLSession = URLSession.shared, imageCache: AutoPurgingImageCache = AutoPurgingImageCache()) {
        self.session = session
        self.imageCache = imageCache
    }
    
    func image(for url: URL, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                self?.watermarkImage(for: data) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            completion(.success(image))
                        } else {
                            completion(.failure(ImageError.dataConversion))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.failure(error ?? ImageError.unidentified))
            }
        }
        dataTask.resume()
    }
    
    func watermarkImage(for imageData: Data, completion: @escaping (Result<Data, any Error>) -> Void) {
        var request = URLRequest(url: URL(string :"https://us-central1-copilot-take-home.cloudfunctions.net/watermark")!)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(String(imageData.count), forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(error ?? ImageError.unidentified))
            }
        }
    }
}

enum ImageError: Error {
    case unidentified
    case dataConversion
}
