import UIKit

protocol TodoListViewProtocol: AnyObject {
    func showTodos(_ todos: [TodoItem])
    func showLoading(_ show: Bool)
    func showError(_ message: String)
}

protocol TodoListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTodo(_ todo: TodoItem)
    func didTapAdd()
    func didSearch(query: String)
    func didDeleteTodo(id: Int64)
    func didToggleTodo(id: Int64)
    func refreshTodos()
}

protocol TodoListInteractorInputProtocol: AnyObject {
    var output: TodoListInteractorOutputProtocol? { get set }
    func fetchTodos()
    func searchTodos(query: String)
    func deleteTodo(id: Int64)
    func toggleTodo(id: Int64)
    func persistNewTodo(_ todo: TodoItem)
    func persistEditedTodo(_ todo: TodoItem)
}

protocol TodoListInteractorOutputProtocol: AnyObject {
    func didFetchTodos(_ todos: [TodoItem])
    func didFail(with error: Error)
}

protocol TodoListRouterProtocol: AnyObject {
    static func createModule() -> UINavigationController
    func navigateToDetail(todo: TodoItem, from view: UIViewController)
    func navigateToCreate(from view: UIViewController, onSave: @escaping (TodoItem) -> Void)
}
