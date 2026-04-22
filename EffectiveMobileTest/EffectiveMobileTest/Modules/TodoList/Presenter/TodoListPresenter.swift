import UIKit

final class TodoListPresenter: TodoListPresenterProtocol {

    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorInputProtocol?
    var router: TodoListRouterProtocol?

    private weak var viewController: UIViewController?

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func viewDidLoad() {
        view?.showLoading(true)
        interactor?.fetchTodos()
    }

    func refreshTodos() {
        interactor?.fetchTodos()
    }

    func didSelectTodo(_ todo: TodoItem) {
        guard let vc = viewController else { return }
        router?.navigateToDetail(todo: todo, from: vc)
    }

    func didTapAdd() {
        guard let vc = viewController else { return }
        router?.navigateToCreate(from: vc) { [weak self] newTodo in
            self?.interactor?.persistNewTodo(newTodo)
        }
    }

    func didSearch(query: String) {
        interactor?.searchTodos(query: query)
    }

    func didDeleteTodo(id: Int64) {
        interactor?.deleteTodo(id: id)
    }

    func didToggleTodo(id: Int64) {
        interactor?.toggleTodo(id: id)
    }
}

extension TodoListPresenter: TodoListInteractorOutputProtocol {

    func didFetchTodos(_ todos: [TodoItem]) {
        view?.showLoading(false)
        view?.showTodos(todos)
    }

    func didFail(with error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}
