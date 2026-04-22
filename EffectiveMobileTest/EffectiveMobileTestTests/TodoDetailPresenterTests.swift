import Testing
import UIKit
@testable import EffectiveMobileTest

@Suite("TodoDetailPresenter")
struct TodoDetailPresenterTests {

    final class MockView: TodoDetailViewProtocol {
        var configuredTodo: TodoItem?
        var validationError: String?
        var dismissed = false

        func configure(with todo: TodoItem?) { configuredTodo = todo }
        func showValidationError(_ message: String) { validationError = message }
        func dismissModule() { dismissed = true }
    }

    final class MockInteractor: TodoDetailInteractorInputProtocol {
        weak var output: TodoDetailInteractorOutputProtocol?
        var savedTitle: String?
        var savedDescription: String?
        var savedIsCompleted: Bool?

        func saveTodo(title: String, description: String, isCompleted: Bool, existing: TodoItem?) {
            savedTitle = title
            savedDescription = description
            savedIsCompleted = isCompleted
            let saved = TodoItem(
                id: existing?.id ?? 1,
                title: title,
                description: description,
                createdAt: existing?.createdAt ?? .now,
                isCompleted: isCompleted
            )
            output?.didSaveTodo(saved)
        }
    }

    @Test("viewDidLoad — конфигурирует View с существующей задачей")
    func viewDidLoadConfiguresExistingTodo() {
        let todo = TodoItem(id: 1, title: "Test", description: "Desc", createdAt: .now, isCompleted: true)
        let view = MockView()
        let presenter = TodoDetailPresenter(existingTodo: todo)
        presenter.view = view
        presenter.viewDidLoad()

        #expect(view.configuredTodo == todo)
    }

    @Test("didTapSave — показывает ошибку при пустом названии")
    func saveWithEmptyTitleShowsValidation() {
        let view = MockView()
        let presenter = TodoDetailPresenter()
        presenter.view = view

        presenter.didTapSave(title: "   ", description: "", isCompleted: false)

        #expect(view.validationError != nil)
    }

    @Test("didTapSave — вызывает saveTodo на интеракторе")
    func saveTappedCallsInteractor() {
        let view = MockView()
        let interactor = MockInteractor()
        let router = MockRouter()
        let presenter = TodoDetailPresenter()
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        presenter.didTapSave(title: "New Task", description: "Desc", isCompleted: false)

        #expect(interactor.savedTitle == "New Task")
        #expect(interactor.savedDescription == "Desc")
        #expect(interactor.savedIsCompleted == false)
    }

    @Test("isEditMode — false для новой задачи, true для существующей")
    func editModeIsSetCorrectly() {
        let createPresenter = TodoDetailPresenter(existingTodo: nil)
        let todo = TodoItem(id: 5, title: "X", description: "", createdAt: .now, isCompleted: false)
        let editPresenter = TodoDetailPresenter(existingTodo: todo)

        #expect(createPresenter.isEditMode == false)
        #expect(editPresenter.isEditMode == true)
    }

    final class MockRouter: TodoDetailRouterProtocol {
        var dismissed = false
        func dismiss(from view: UIViewController) { dismissed = true }
    }
}
