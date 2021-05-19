//
//  Network.swift
//  ios-tutorial
//
//  Created by sato.ken on 2021/05/19.
//

import Alamofire
import Combine
import Foundation

final class Network {
    private enum Const {
        static let acceptableStatusCode = 200 ..< 300
        static let acceptableContentType = ["application/json"]
    }

    private static var session = Session()

    static func request<Request, Response>(_ request: Request) -> AnyPublisher<Response, Error> where Request: BaseRequest, Response == Request.Response {
        DataResponsePublisher<Response>(afRequest(request), queue: .main, serializer: DecodableResponseSerializer())
            .tryMap { response in
                switch response.result {
                    case .success(let decoded):
                        return decoded
                    case .failure(let error):
                        throw error
                }
            }.eraseToAnyPublisher()
    }
    
    private static func afRequest<Request: BaseRequest>(_ request: Request) -> DataRequest {
        session.request(request)
            .validate(contentType: Const.acceptableContentType)
            .validate(statusCode: Const.acceptableStatusCode)
    }
}
