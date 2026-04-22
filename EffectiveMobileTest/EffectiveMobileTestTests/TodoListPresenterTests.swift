import Testing
import Foundation
@testable import EffectiveMobileTest

@Suite("TodoListPresenter")
struct TodoListPresenterTests {

    final class MockView: TodoListViewProtocol {
        var shownTodos: [TodoItem] = []
        var loadingState: Bool = false
        var errorMessage: String?

        func showTodos(_ todos: [TodoItem]) { shownTodos = todos }
        func showLoading(_ show: Bool) { loadingState = show }
        func showError(_ message: String) { errorMessage = message }
    }

    final class MockInteractor: TodoListInteractorInputProtocol {
        weak var output: TodoListInteractorOutputProtocol?
        var fetchCalled = false
        var deletedId: Int64?
        var toggledId: Int64?
        var searchQuery: String?

        func fetchTodos() { fetchCalled = true }
        func searchTodos(query: String) { searchQuery = query }
        func deleteTodo(id: Int64) { deletedId = id }
        func toggleTodo(id: Int64) { toggledId = id }
        func persistNewTodo(_ todo: TodoItem) {}
        func persistEditedTodo(_ todo: TodoItem) {}
    }

    @Test("viewDidLoad вызывает fetchTodos и showLoading")
    func viewDidLoadTriggersFetch() {
        let view = MockView()
        let interactor = MockInteractor()
        let presenter = TodoListPresenter()

        presenter.view = view
        presenter.interactor = interactor

        presenter.viewDidLoad()

        #expect(interactor.fetchCalled)
        #expect(view.loadingState == true)
    }

    @Test("didFetchTodos передаёт задачи во View")
    func didFetchTodosUpdatesView() {
        let view = MockView()
        let presenter = TodoListPresenter()
        presenter.view = view

        let todos = [
            TodoItem(id: 1, title: "A", description: "", createdAt: .now, isCompleted: false)
        ]
        presenter.didFetchTodos(todos)

        #expect(view.shownTodos.count == 1)
        #expect(view.loadingState == false)
    }

    @Test("didFail передаёт ошибку во View")
    func didFailShowsError() {
        let view = MockView()
        let presenter = TodoListPresenter()
        presenter.view = view

        presenter.didFail(with: URLError(.notConnectedToInternet))

        #expect(view.errorMessage != nil)
        #expect(view.loadingState == false)
    }

    @Test("didDeleteTodo вызывает deleteTodo на интеракторе")
    func didDeleteTodoCallsInteractor() {
        let interactor = MockInteractor()
        let presenter = TodoListPresenter()
        presenter.interactor = interactor

        presenter.didDeleteTodo(id: 7)

        #expect(interactor.deletedId == 7)
    }

    @Test("didToggleTodo вызывает toggleTodo на интеракторе")
    func didToggleTodoCallsInteractor() {
        let interactor = MockInteractor()
        let presenter = TodoListPresenter()
        presenter.interactor = interactor

        presenter.didToggleTodo(id: 13)

        #expect(interactor.toggledId == 13)
    }

    @Test("didSearch передаёт запрос интерактору")
    func didSearchCallsInteractor() {
        let interactor = MockInteractor()
        let presenter = TodoListPresenter()
        presenter.interactor = interactor

        presenter.didSearch(query: "Swift")

        #expect(interactor.searchQuery == "Swift")
    }
}
