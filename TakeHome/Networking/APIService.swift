//
//  APIService.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import Apollo
import Foundation

protocol ApiServiceProtocol {
    func fetchBirdsList(completion: @escaping (Result<GraphQLResult<GraphQL.BirdsQuery.Data>, any Error>) -> Void)
    func fetchBird(for id: GraphQL.ID, completion: @escaping (Result<GraphQLResult<GraphQL.BirdQuery.Data>, any Error>) -> Void)
    func addNote(_ comment: String, for id: GraphQL.ID, timestamp: Int, completion: @escaping (Result<GraphQLResult<GraphQL.AddNoteMutation.Data>, any Error>) -> Void)
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
    
    func fetchBirdsList(completion: @escaping (Result<Apollo.GraphQLResult<GraphQL.BirdsQuery.Data>, any Error>) -> Void) {
        client.fetch(query: GraphQL.BirdsQuery()) { result in
            completion(result)
        }
    }
    
    func fetchBird(for id: GraphQL.ID, completion: @escaping (Result<Apollo.GraphQLResult<GraphQL.BirdQuery.Data>, any Error>) -> Void) {
        client.fetch(query: GraphQL.BirdQuery(id: id)) { result in
            completion(result)
        }
    }
    
    func addNote(_ comment: String, for id: GraphQL.ID, timestamp: Int, completion: @escaping (Result<GraphQLResult<GraphQL.AddNoteMutation.Data>, any Error>) -> Void) {
        client.perform(mutation: GraphQL.AddNoteMutation(birdId: id, comment: comment, timestamp: timestamp)) { result in
            completion(result)
        }
    }
    
    
}
