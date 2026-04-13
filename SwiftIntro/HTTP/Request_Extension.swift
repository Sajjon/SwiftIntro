//
//  Request_Extension.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation
import Alamofire

protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
}

protocol ResponseCollectionSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self] {
        var collection: [Self] = []

        if let representation = representation as? [[String: Any]] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation) {
                    collection.append(item)
                }
            }
        }

        return collection
    }
}

extension DataRequest {

    @discardableResult
    func responseObject<T: ResponseObjectSerializable>(
        queue: DispatchQueue = .main,
        completionHandler: @escaping (Swift.Result<T, MyError>) -> Void) -> Self
    {
        return responseData(queue: queue) { response in
            switch response.result {
            case .failure(let error):
                completionHandler(.failure(MyError(.network, error: error)))
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    guard let httpResponse = response.response,
                          let obj = T(response: httpResponse, representation: json) else {
                        completionHandler(.failure(MyError(.modelMapping, description: "JSON could not be serialized")))
                        return
                    }
                    completionHandler(.success(obj))
                } catch {
                    completionHandler(.failure(MyError(.jsonParsing, error: error)))
                }
            }
        }
    }

    @discardableResult
    func responseCollection<T: ResponseCollectionSerializable>(
        queue: DispatchQueue = .main,
        completionHandler: @escaping (Swift.Result<[T], MyError>) -> Void) -> Self
    {
        return responseData(queue: queue) { response in
            switch response.result {
            case .failure(let error):
                completionHandler(.failure(MyError(.network, error: error)))
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    guard let httpResponse = response.response else {
                        completionHandler(.failure(MyError(.modelMapping, description: "Response collection could not be serialized due to nil response.")))
                        return
                    }
                    completionHandler(.success(T.collection(from: httpResponse, withRepresentation: json)))
                } catch {
                    completionHandler(.failure(MyError(.jsonParsing, error: error)))
                }
            }
        }
    }
}
