import XCTest
@testable import mixipre23

@MainActor
final class ReoiListViewModelTests: XCTestCase {
    func test_onAppear_正常系() async {
        let viewModel = RepoListViewModel(
            repoAPIClient: MockRepositoryAPIClient(
                repos: [.mock1, .mock2]
            )
        )
        
        await viewModel.onAppear()
        
        switch viewModel.state {
        case let .loaded(repos):
            XCTAssertEqual(repos, [Repo.mock1, Repo.mock2])
        default:
            XCTFail()
        }
    }
    
    
    struct MockRepositoryAPIClient: RepoAPIClientProtocol {
        let repos: [Repo]
        
        func getRepos() async throws -> [Repo] {
            repos
        }
    }
}
