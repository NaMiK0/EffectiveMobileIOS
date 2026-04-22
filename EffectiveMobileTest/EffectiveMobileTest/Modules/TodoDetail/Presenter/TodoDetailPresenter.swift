import UIKit

final class TodoDetailPresenter: TodoDetailPresenterProtocol {

    weak var view: TodoDetailViewProtocol?
    var interactor: TodoDetailInteractorInputProtocol?
    var router: TodoDetailRouterProtocol?

    private weak var viewController: UIViewController?
    private let existingTodo: TodoItem?
    private let onSave: ((TodoItem) -> Void)?

    var isEditMode: Bool { existingTodo != nil }

    init(existingTodo: TodoItem? = nil, onSave: ((TodoItem) -> Void)? = nil) {
        self.existingTodo = existingTodo
        self.onSave = onSave
    }

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func viewDidLoad() {
        view?.configure(with: existingTodo)
    }

    func didTapSave(title: String, description: String, isCompleted: Bool) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.showValidationError("Название задачи не может быть пустым")
            return
        }
        interactor?.saveTodo(
            title: trimmed,
            description: description,
            isCompleted: isCompleted,
            existing: existingTodo
        )
    }

    func didTapCancel() {
        guard let vc = viewController else { return }
        router?.dismiss(from: vc)
    }
}

extension TodoDetailPresenter: TodoDetailInteractorOutputProtocol {

    func didSaveTodo(_ todo: TodoItem) {
        onSave?(todo)
        guard let vc = viewController else { return }
        router?.dismiss(from: vc)
    }

    func didFail(with error: Error) {
        view?.showValidationError(error.localizedDescription)
    }
}
