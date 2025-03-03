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
    
  }
}
