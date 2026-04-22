import UIKit

final class TodoListRouter: TodoListRouterProtocol {

    static func createModule() -> UINavigationController {
        TodoListAssembly.createModule()
    }

    func navigateToDetail(todo: TodoItem, from view: UIViewController) {
        let vc = TodoDetailAssembly.createModule(
            existing: todo,
            onSave: { saved in
                if let listVC = view as? TodoListViewController {
                    listVC.presenter?.refreshTodos()
                }
            }
        )
        view.navigationController?.pushViewController(vc, animated: true)
    }

    func navigateToCreate(from view: UIViewController, onSave: @escaping (TodoItem) -> Void) {
        let vc = TodoDetailAssembly.createModule(existing: nil, onSave: onSave)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        view.present(nav, animated: true)
    }
}
