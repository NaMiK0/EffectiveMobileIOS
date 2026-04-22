import UIKit

enum TodoDetailAssembly {

    static func createModule(existing: TodoItem?, onSave: ((TodoItem) -> Void)?) -> TodoDetailViewController {
        let view = TodoDetailViewController()
        let presenter = TodoDetailPresenter(existingTodo: existing, onSave: onSave)
        let interactor = TodoDetailInteractor()
        let router = TodoDetailRouter()

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.attach(viewController: view)

        interactor.output = presenter

        view.presenter = presenter
        return view
    }
}
