import UIKit

final class TodoDetailViewController: UIViewController {

    var presenter: TodoDetailPresenterProtocol?

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название задачи"
        tf.font = .systemFont(ofSize: 22, weight: .semibold)
        tf.textColor = AppColors.textPrimary
        tf.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: [.foregroundColor: AppColors.textSecondary]
        )
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.returnKeyType = .next
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var titleSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var descTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = AppColors.textPrimary
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var descPlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "Описание (необязательно)"
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = AppColors.textSecondary
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isUserInteractionEnabled = false
        return lbl
    }()

    private lazy var descSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var completedLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Выполнена"
        lbl.font = .systemFont(ofSize: 17)
        lbl.textColor = AppColors.textPrimary
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var completedSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = AppColors.accent
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    private lazy var toggleRow: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.surfaceElevated
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = AppColors.textSecondary
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Сохранить"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = AppColors.accent
        config.cornerStyle = .large
        config.titleTextAttributesTransformer = .init { attrs in
            var a = attrs
            a.font = .systemFont(ofSize: 17, weight: .semibold)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        descTextView.delegate = self
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = AppColors.background

        let isModal = presenter?.isEditMode == false

        if isModal {
            title = "Новая задача"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped)
            )
            applyNavBarStyle()
        } else {
            title = "Редактировать"
        }

        toggleRow.addSubview(completedLabel)
        toggleRow.addSubview(completedSwitch)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleField)
        contentView.addSubview(titleSeparator)
        contentView.addSubview(descTextView)
        contentView.addSubview(descPlaceholder)
        contentView.addSubview(descSeparator)
        contentView.addSubview(toggleRow)
        contentView.addSubview(dateLabel)
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            titleSeparator.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
            titleSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            descTextView.topAnchor.constraint(equalTo: titleSeparator.bottomAnchor, constant: 16),
            descTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            descPlaceholder.topAnchor.constraint(equalTo: descTextView.topAnchor),
            descPlaceholder.leadingAnchor.constraint(equalTo: descTextView.leadingAnchor),

            descSeparator.topAnchor.constraint(equalTo: descTextView.bottomAnchor, constant: 10),
            descSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            toggleRow.topAnchor.constraint(equalTo: descSeparator.bottomAnchor, constant: 24),
            toggleRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            toggleRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            toggleRow.heightAnchor.constraint(equalToConstant: 52),

            completedLabel.leadingAnchor.constraint(equalTo: toggleRow.leadingAnchor, constant: 16),
            completedLabel.centerYAnchor.constraint(equalTo: toggleRow.centerYAnchor),

            completedSwitch.trailingAnchor.constraint(equalTo: toggleRow.trailingAnchor, constant: -16),
            completedSwitch.centerYAnchor.constraint(equalTo: toggleRow.centerYAnchor),

            dateLabel.topAnchor.constraint(equalTo: toggleRow.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            saveButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 52),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func applyNavBarStyle() {
        guard let nav = navigationController else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.surface
        appearance.titleTextAttributes = [.foregroundColor: AppColors.textPrimary]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = AppColors.accent
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = max(0, view.bounds.height - frame.minY)
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        presenter?.didTapSave(
            title: titleField.text ?? "",
            description: descTextView.text ?? "",
            isCompleted: completedSwitch.isOn
        )
    }

    @objc private func cancelTapped() {
        presenter?.didTapCancel()
    }
}

extension TodoDetailViewController: TodoDetailViewProtocol {

    func configure(with todo: TodoItem?) {
        if let todo {
            titleField.text = todo.title
            descTextView.text = todo.description
            descPlaceholder.isHidden = !todo.description.isEmpty
            completedSwitch.isOn = todo.isCompleted
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            dateLabel.text = "Создана: \(formatter.string(from: todo.createdAt))"
        } else {
            descPlaceholder.isHidden = false
            completedSwitch.isOn = false
            dateLabel.text = ""
            titleField.becomeFirstResponder()
        }
    }

    func showValidationError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = AppColors.accent
        present(alert, animated: true)
    }

    func dismissModule() {
        presenter?.didTapCancel()
    }
}

extension TodoDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descTextView.becomeFirstResponder()
        return false
    }
}

extension TodoDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}
