import UIKit

final class TodoTableViewCell: UITableViewCell {

    static let reuseID = "TodoTableViewCell"

    var onToggle: (() -> Void)?

    private let checkButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let descLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = AppColors.textDisabled
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = AppColors.surface
        selectionStyle = .none

        let selectedBg = UIView()
        selectedBg.backgroundColor = AppColors.surfaceElevated
        selectedBackgroundView = selectedBg

        checkButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(checkButton)
        contentView.addSubview(textStack)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            checkButton.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            separator.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    func configure(with todo: TodoItem) {
        let completed = todo.isCompleted

        let icon = UIImage(
            systemName: completed ? "checkmark.circle.fill" : "circle",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        )
        checkButton.setImage(icon, for: .normal)
        checkButton.tintColor = completed ? AppColors.accent : AppColors.textSecondary

        if completed {
            let attrs: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: AppColors.textDisabled
            ]
            titleLabel.attributedText = NSAttributedString(string: todo.title, attributes: attrs)
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = todo.title
            titleLabel.textColor = AppColors.textPrimary
        }

        if todo.description.isEmpty {
            descLabel.isHidden = true
        } else {
            descLabel.isHidden = false
            descLabel.text = todo.description
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: todo.createdAt)
    }

    @objc private func toggleTapped() {
        onToggle?()
    }
}
