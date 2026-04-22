import UIKit

final class TodoDetailRouter: TodoDetailRouterProtocol {

    func dismiss(from view: UIViewController) {
        if view.navigationController?.viewControllers.first === view {
            view.dismiss(animated: true)
        } else {
            view.navigationController?.popViewController(animated: true)
        }
    }
}
