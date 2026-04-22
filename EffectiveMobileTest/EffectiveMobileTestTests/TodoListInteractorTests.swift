import Testing
import Foundation
@testable import EffectiveMobileTest

@Suite("TodoListInteractor")
struct TodoListInteractorTests {

    final class MockOutput: TodoListInteractorOutputProtocol {
        var fetchedTodos: [TodoItem] = []
        var receivedError: Error?
        var fetchCalled = false

        func didFetchTodos(_ todos: [TodoItem]) {
            fetchedTodos = todos
            fetchCalled = true
        }

        func didFail(with error: Error) {
            receivedError = error
        }
    }

    final class MockNetworkService: NetworkServiceProtocol {
        var stubbedResult: Result<[TodoItem], Error> = .success([])

        func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
            completion(stubbedResult)
        }
    }

    @Test("fetchTodos — загружает данные из сети при первом запуске")
    func fetchTodosLoadsFromNetwork() async throws {
        let networkMock = MockNetworkService()
        let expected = [
            TodoItem(id: 1, title: "Task 1", description: "", createdAt: .now, isCompleted: false),
            TodoItem(id: 2, title: "Task 2", description: "Desc", createdAt: .now, isCompleted: true)
        ]
        networkMock.stubbedResult = .success(expected)

        let output = MockOutput()
        let coreData = CoreDataStack.inMemory()
        let interactor = TodoListInteractor(networkService: networkMock, coreData: coreData)
        interactor.output = output

        interactor.fetchTodos()

        try await Task.sleep(for: .milliseconds(500))

        #expect(output.fetchCalled)
        #expect(output.fetchedTodos.count == expected.count)
    }

    @Test("fetchTodos — возвращает ошибку при сетевом сбое")
    func fetchTodosReturnsError() async throws {
        let networkMock = MockNetworkService()
        networkMock.stubbedResult = .failure(URLError(.notConnectedToInternet))

        let output = MockOutput()
        let coreData = CoreDataStack.inMemory()
        let interactor = TodoListInteractor(networkService: networkMock, coreData: coreData)
        interactor.output = output

        interactor.fetchTodos()

        try await Task.sleep(for: .milliseconds(500))

        #expect(output.receivedError != nil)
    }

    @Test("deleteTodo — удаляет задачу из хранилища")
    func deleteTodoRemovesItem() async throws {
        let networkMock = MockNetworkService()
        let todo = TodoItem(id: 99, title: "Delete me", description: "", createdAt: .now, isCompleted: false)
        networkMock.stubbedResult = .success([todo])

        let output = MockOutput()
        let coreData = CoreDataStack.inMemory()
        let interactor = TodoListInteractor(networkService: networkMock, coreData: coreData)
        interactor.output = output

        interactor.fetchTodos()
        try await Task.sleep(for: .milliseconds(500))

        interactor.deleteTodo(id: 99)
        try await Task.sleep(for: .milliseconds(500))

        #expect(!output.fetchedTodos.contains(where: { $0.id == 99 }))
    }

    @Test("toggleTodo — меняет статус выполнения")
    func toggleTodoFlipsStatus() async throws {
        let networkMock = MockNetworkService()
        let todo = TodoItem(id: 42, title: "Toggle me", description: "", createdAt: .now, isCompleted: false)
        networkMock.stubbedResult = .success([todo])

        let output = MockOutput()
        let coreData = CoreDataStack.inMemory()
        let interactor = TodoListInteractor(networkService: networkMock, coreData: coreData)
        interactor.output = output

        interactor.fetchTodos()
        try await Task.sleep(for: .milliseconds(500))

        interactor.toggleTodo(id: 42)
        try await Task.sleep(for: .milliseconds(500))

        let toggled = output.fetchedTodos.first(where: { $0.id == 42 })
        #expect(toggled?.isCompleted == true)
    }
}
