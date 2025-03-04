//
//  ImageService.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import AlamofireImage
import UIKit

protocol ImageServiceProtocol {
    func image(for key: String) -> UIImage?
    func image(for url: URL, key: String, completion: @escaping (Result<UIImage, any Error>) -> Void)
    func cancelDownload(for key: String)
}

final class ImageService: ImageServiceProtocol {
    static let shared = ImageService()
    
    private let session: URLSession
    private let imageCache: AutoPurgingImageCache
    
    private var taskDictionary: [String: URLSessionDataTask] = [:]
    
    init(session: URLSession = URLSession.shared, imageCache: AutoPurgingImageCache = AutoPurgingImageCache(memoryCapacity: 300_000_000)) {
        self.session = session
        self.imageCache = imageCache
    }
    
    func image(for key: String) -> UIImage? {
        return imageCache.image(withIdentifier: key)
    }
    
    func image(for url: URL, key: String, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        if let image = imageCache.image(withIdentifier: key) {
            completion(.success(image))
            return
        }
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                self?.watermarkImage(for: data, key: key) { [weak self] result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            self?.imageCache.add(image, withIdentifier: key)
                            completion(.success(image))
                        } else {
                            completion(.failure(ImageError.dataConversion))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    self?.taskDictionary.removeValue(forKey: key)
                }
            } else {
                completion(.failure(error ?? ImageError.unidentified))
            }
        }
        taskDictionary[key] = dataTask
        dataTask.resume()
    }
    
    private func watermarkImage(for imageData: Data, key: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        var request = URLRequest(url: URL(string :"https://us-central1-copilot-take-home.cloudfunctions.net/watermark")!)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(String(imageData.count), forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = imageData
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(error ?? ImageError.unidentified))
            }
        }
        taskDictionary[key] = dataTask
        dataTask.resume()
    }
    
    func cancelDownload(for key: String) {
        taskDictionary[key]?.cancel()
        taskDictionary.removeValue(forKey: key)
    }
}

enum ImageError: Error {
    case unidentified
    case dataConversion
    case missingURL
}
