
import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    enum APIError: Error {
        case faileedToGetData
        
    }
    // MARK: - Albums
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion( .failure(APIError.faileedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion( .success(result))
                }
                catch {
                    completion( .failure(error))
                }
            }
            task.resume()
        }
    }
    // MARK: - Playlists
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion( .failure(APIError.faileedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion( .success(result))
                }
                catch {
                    completion( .failure(error))
                }
            }
            task.resume()
        }
    }
    // MARK: - Profile
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
    }
    
    // MARK: - Browse
    
    public func getNewReleases(completion: @escaping ((Result<NewRealesesResponse, Error>)) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(NewRealesesResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping((Result<FeaturedPlaylistResponse, Error>) -> Void)){
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=22"),
            type: .GET) {
            request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.faileedToGetData))
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                       
                        completion(.success(result))
                    }
                    catch {
                        completion(.failure(error))
                        
                    }
                }
                task.resume()
            }
        }
        
    public func getRecommendation(genres: Set<String>, completion: @escaping ((Result<RecommendationResponse, Error>) -> Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"),
            type: .GET){
                request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.faileedToGetData))
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                       // print(result)
                       completion(.success(result))
                    }
                    catch {
                        completion(.failure(error))

                    }
                }
                task.resume()

            }
    }
    public func getRecommendedGenres(completion: @escaping((Result<RecommendedGenresResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
                      type: .GET) {
            request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                 //  print(json)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                    
                }
            }
            task.resume()
        }
    }
    
    enum HTTPMethod: String{
        case GET
        case POST
    }
    
    private func createRequest(with url: URL?,
                               type: HTTPMethod,
                               completion: @escaping(URLRequest) -> Void){
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
            
        }
    }
}