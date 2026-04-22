import Foundation
import CoreData

final class TodoDetailInteractor: TodoDetailInteractorInputProtocol {

    weak var output: TodoDetailInteractorOutputProtocol?

    private let coreData: CoreDataStack
    private let backgroundQueue = DispatchQueue(label: "com.todo.detail.interactor", qos: .userInitiated)

    init(coreData: CoreDataStack = .shared) {
        self.coreData = coreData
    }

    func saveTodo(title: String, description: String, isCompleted: Bool, existing: TodoItem?) {
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            let ctx = self.coreData.newBackgroundContext()
            ctx.performAndWait {
                let obj: TodoItemMO
                if let existing {
                    let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                    request.predicate = NSPredicate(format: "id == %lld", existing.id)
                    obj = (try? ctx.fetch(request).first) ?? TodoItemMO(context: ctx)
                    obj.id = existing.id
                    obj.createdAt = existing.createdAt
                } else {
                    obj = TodoItemMO(context: ctx)
                    obj.id = Int64(Date().timeIntervalSince1970 * 1000)
                    obj.createdAt = Date()
                }
                obj.title = title
                obj.desc = description
                obj.isCompleted = isCompleted
                try? ctx.save()

                let saved = obj.toDomain()
                DispatchQueue.main.async { self.output?.didSaveTodo(saved) }
            }
        }
    }
}
