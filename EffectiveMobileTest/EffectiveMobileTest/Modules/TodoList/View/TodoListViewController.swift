import UIKit

final class TodoListViewController: UIViewController {

    var presenter: TodoListPresenterProtocol?

    private var todos: [TodoItem] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = AppColors.background
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.register(TodoTableViewCell.self, forCellReuseIdentifier: TodoTableViewCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Поиск задач"
        sc.searchBar.tintColor = AppColors.accent
        sc.searchBar.searchTextField.backgroundColor = AppColors.surfaceElevated
        sc.searchBar.searchTextField.textColor = AppColors.textPrimary
        sc.searchBar.searchTextField.leftView?.tintColor = AppColors.textSecondary
        sc.searchResultsUpdater = self
        return sc
    }()

    private lazy var countLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = AppColors.textSecondary
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var countBar: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.surface
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = AppColors.accent
        btn.tintColor = .black
        let img = UIImage(systemName: "plus", withConfiguration:
            UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        btn.setImage(img, for: .normal)
        btn.layer.cornerRadius = 28
        btn.layer.shadowColor = AppColors.accent.cgColor
        btn.layer.shadowRadius = 12
        btn.layer.shadowOpacity = 0.45
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = AppColors.accent
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private lazy var emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Задач нет.\nНажмите + чтобы добавить."
        lbl.textColor = AppColors.textSecondary
        lbl.font = .systemFont(ofSize: 15)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        title = "Задачи"
        view.backgroundColor = AppColors.background
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let countBarSeparator = UIView()
        countBarSeparator.backgroundColor = AppColors.separator
        countBarSeparator.translatesAutoresizingMaskIntoConstraints = false

        countBar.addSubview(countLabel)
        countBar.addSubview(countBarSeparator)

        view.addSubview(countBar)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            countBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            countBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countBar.heightAnchor.constraint(equalToConstant: 36),

            countLabel.centerXAnchor.constraint(equalTo: countBar.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: countBar.centerYAnchor),

            countBarSeparator.bottomAnchor.constraint(equalTo: countBar.bottomAnchor),
            countBarSeparator.leadingAnchor.constraint(equalTo: countBar.leadingAnchor),
            countBarSeparator.trailingAnchor.constraint(equalTo: countBar.trailingAnchor),
            countBarSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            tableView.topAnchor.constraint(equalTo: countBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func updateCountLabel() {
        let count = todos.count
        countLabel.text = "\(count) \(todosWord(count))"
        emptyLabel.isHidden = count > 0
    }

    private func todosWord(_ n: Int) -> String {
        let mod10 = n % 10, mod100 = n % 100
        if mod100 >= 11 && mod100 <= 19 { return "задач" }
        switch mod10 {
        case 1: return "задача"
        case 2, 3, 4: return "задачи"
        default: return "задач"
        }
    }

    @objc private func addTapped() {
        presenter?.didTapAdd()
    }
}

extension TodoListViewController: TodoListViewProtocol {

    func showTodos(_ todos: [TodoItem]) {
        self.todos = todos
        tableView.reloadData()
        updateCountLabel()
    }

    func showLoading(_ show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        tableView.isHidden = show
        countBar.isHidden = show
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = AppColors.accent
        present(alert, animated: true)
    }
}

extension TodoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoTableViewCell.reuseID, for: indexPath
        ) as! TodoTableViewCell
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        cell.onToggle = { [weak self] in
            self?.presenter?.didToggleTodo(id: todo.id)
        }
        return cell
    }
}

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectTodo(todos[indexPath.row])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let todo = todos[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, done in
            self?.confirmDelete(todo: todo, completion: done)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = AppColors.destructive
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let todo = todos[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self?.presenter?.didSelectTodo(todo)
            }
            let toggle = UIAction(
                title: todo.isCompleted ? "Пометить активной" : "Пометить выполненной",
                image: UIImage(systemName: todo.isCompleted ? "circle" : "checkmark.circle")
            ) { _ in
                self?.presenter?.didToggleTodo(id: todo.id)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.presenter?.didDeleteTodo(id: todo.id)
            }
            return UIMenu(children: [edit, toggle, delete])
        }
    }

    private func confirmDelete(todo: TodoItem, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Удалить задачу?",
            message: "\"\(todo.title)\" будет удалена навсегда.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in completion(false) })
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter?.didDeleteTodo(id: todo.id)
            completion(true)
        })
        alert.view.tintColor = AppColors.accent
        present(alert, animated: true)
    }
}

extension TodoListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        presenter?.didSearch(query: query)
    }
}
