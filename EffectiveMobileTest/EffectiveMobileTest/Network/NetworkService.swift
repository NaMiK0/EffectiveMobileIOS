import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    private struct APIResponse: Decodable {
        struct APITodo: Decodable {
            let id: Int
            let todo: String
            let completed: Bool
        }
        let todos: [APITodo]
    }

    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos?limit=30") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data else {
                DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                return
            }
            do {
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
                let items = response.todos.map { todo in
                    TodoItem(
                        id: Int64(todo.id),
                        title: todo.todo,
                        description: "",
                        createdAt: Date(),
                        isCompleted: todo.completed
                    )
                }
                DispatchQueue.main.async { completion(.success(items)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
