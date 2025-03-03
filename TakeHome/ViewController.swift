import Apollo
import UIKit

class ViewController: UIViewController {
  var client: ApolloClient!

  override func viewDidLoad() {
    super.viewDidLoad()

    client = createClient(
      accessToken: "E8RTOTpkCq7WzFqqKVtH",
      url: URL(string: "https://takehome.graphql.copilot.money")!
    )
    client.fetch(query: GraphQL.BirdsQuery()) { result in
        switch result {
        case .success(let gqlResult):
            if let list = gqlResult.data?.birds {
                print(list)
            }
        case .failure(let error):
            print("failed")
        }
    }
  }
}
