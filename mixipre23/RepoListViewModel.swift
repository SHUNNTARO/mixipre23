import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    
    @Published private(set) var state: Stateful<[Repo]> = .loading
    private let repoAPIClient: RepoAPIClientProtocol
    
    init(repoAPIClient: RepoAPIClientProtocol = RepoAPIClient()) {
            self.repoAPIClient = repoAPIClient
        }
    
    func onAppear() async {
        await loadRepos()
    }
    
    func onRetryButtonTapped() async {
        await loadRepos()
    }
    
    private func loadRepos() async {
        state = .loading
        
        do {
            let value = try await RepoAPIClient().getRepos()
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}




