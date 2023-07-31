import SwiftUI

@MainActor
class ReposStore: ObservableObject {
    @Published private(set) var state: Stateful<[Repo]> = .loading
    
    func loadRepos() async {
        state = .loading
        
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github+json"
        ]
        
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)
            
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}


struct RepoListView: View {
    @StateObject private var viewModel = RepoListViewModel()
    
    var body: some View {
        NavigationView {
            Group{
                switch viewModel.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(destination: RepoDetailView(repo: repo)) {
                            RepoRow(repo: repo)
                        }
                    }
                case .failed:
                    VStack {
                        Text("Failed to load repositories")
                        Button(
                            action: {
                                Task {
                                    await viewModel.onRetryButtonTapped()
                                }
                            },
                            label: {
                                Text("Retry")
                            }
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Repository") 
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

    


struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}


