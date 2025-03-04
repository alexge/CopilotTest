//
//  APIService.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import Apollo
import Foundation

protocol ApiServiceProtocol {
    func fetchBirdsList(completion: @escaping (Result<[BirdsListItem], any Error>) -> Void)
    func fetchBird(for id: GraphQL.ID, completion: @escaping (Result<BirdDetailItem, any Error>) -> Void)
    func addNote(_ comment: String, for id: GraphQL.ID, timestamp: Int, completion: @escaping (Result<Bool, any Error>) -> Void)
}

final class ApiService: ApiServiceProtocol {
    private static let defaultClient: ApolloClient = createClient(
        accessToken: "E8RTOTpkCq7WzFqqKVtH",
        url: URL(string: "https://takehome.graphql.copilot.money")!
    )
    
    private let client: ApolloClient
    
    init(client: ApolloClient = ApiService.defaultClient) {
        self.client = client
    }
    
    func fetchBirdsList(completion: @escaping (Result<[BirdsListItem], any Error>) -> Void) {
        client.fetch(query: GraphQL.BirdsQuery()) { result in
            switch result {
            case .success(let gqlResult):
                if let data = gqlResult.data {
                    completion(.success(data.birds.map { BirdsListItem(id: $0.id, name: $0.latin_name, url: URL(string: $0.image_url)) }))
                } else {
                    completion(.failure(APIError.missingData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBird(for id: GraphQL.ID, completion: @escaping (Result<BirdDetailItem, any Error>) -> Void) {
        client.fetch(query: GraphQL.BirdQuery(id: id)) { result in
            switch result {
            case .success(let gqlResult):
                if let data = gqlResult.data, let bird = data.bird {
                    completion(.success(BirdDetailItem(id: bird.id, name: bird.latin_name, url: URL(string: bird.image_url), notes: bird.notes.map { NoteItem(comment: $0.comment, timeStamp: Double($0.timestamp)) })))
                } else {
                    completion(.failure(APIError.missingData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addNote(_ comment: String, for id: GraphQL.ID, timestamp: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
        client.perform(mutation: GraphQL.AddNoteMutation(birdId: id, comment: comment, timestamp: timestamp)) { result in
            switch result {
            case .success(let res):
                if (res.errors ?? []).isEmpty {
                    completion(.success(true))
                } else {
                    completion(.failure(res.errors![0]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum APIError: Error {
    case missingData
}
