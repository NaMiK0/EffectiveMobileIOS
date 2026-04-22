import UIKit

enum TodoListAssembly {

    static func createModule() -> UINavigationController {
        let view = TodoListViewController()
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor()
        let router = TodoListRouter()

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.attach(viewController: view)

        interactor.output = presenter

        view.presenter = presenter

        let nav = UINavigationController(rootViewController: view)
        applyNavBarStyle(nav)
        return nav
    }

    private static func applyNavBarStyle(_ nav: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.surface
        appearance.titleTextAttributes = [.foregroundColor: AppColors.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: AppColors.textPrimary]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = AppColors.accent
        nav.navigationBar.prefersLargeTitles = true
    }
}
