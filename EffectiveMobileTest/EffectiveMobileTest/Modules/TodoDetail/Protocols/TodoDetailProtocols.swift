import UIKit

protocol TodoDetailViewProtocol: AnyObject {
    func configure(with todo: TodoItem?)
    func showValidationError(_ message: String)
    func dismissModule()
}

protocol TodoDetailPresenterProtocol: AnyObject {
    var isEditMode: Bool { get }
    func viewDidLoad()
    func didTapSave(title: String, description: String, isCompleted: Bool)
    func didTapCancel()
}

protocol TodoDetailInteractorInputProtocol: AnyObject {
    var output: TodoDetailInteractorOutputProtocol? { get set }
    func saveTodo(title: String, description: String, isCompleted: Bool, existing: TodoItem?)
}

protocol TodoDetailInteractorOutputProtocol: AnyObject {
    func didSaveTodo(_ todo: TodoItem)
    func didFail(with error: Error)
}

protocol TodoDetailRouterProtocol: AnyObject {
    func dismiss(from view: UIViewController)
}
