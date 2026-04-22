import Foundation
import CoreData

final class TodoListInteractor: TodoListInteractorInputProtocol {

    weak var output: TodoListInteractorOutputProtocol?

    private let networkService: NetworkServiceProtocol
    private let coreData: CoreDataStack
    private let backgroundQueue = DispatchQueue(label: "com.todo.interactor", qos: .userInitiated)
    private var isInitialLoadDone = false

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        coreData: CoreDataStack = .shared
    ) {
        self.networkService = networkService
        self.coreData = coreData
    }

    func fetchTodos() {
        let ctx = coreData.newBackgroundContext()
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            ctx.performAndWait {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

                if let objects = try? ctx.fetch(request), (!objects.isEmpty || self.isInitialLoadDone) {
                    let todos = objects.map { $0.toDomain() }
                    DispatchQueue.main.async { self.output?.didFetchTodos(todos) }
                    return
                }

                self.isInitialLoadDone = true
                self.networkService.fetchTodos { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let todos):
                        self.backgroundQueue.async {
                            self.store(todos)
                            DispatchQueue.main.async { self.output?.didFetchTodos(todos) }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async { self.output?.didFail(with: error) }
                    }
                }
            }
        }
    }

    func searchTodos(query: String) {
        let ctx = coreData.newBackgroundContext()
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            ctx.performAndWait {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                    request.predicate = NSPredicate(
                        format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@",
                        query, query
                    )
                }
                let todos = (try? ctx.fetch(request))?.map { $0.toDomain() } ?? []
                DispatchQueue.main.async { self.output?.didFetchTodos(todos) }
            }
        }
    }

    func deleteTodo(id: Int64) {
        let ctx = coreData.newBackgroundContext()
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            ctx.performAndWait {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.predicate = NSPredicate(format: "id == %lld", id)
                if let obj = try? ctx.fetch(request).first {
                    ctx.delete(obj)
                    try? ctx.save()
                }
            }
            self.fetchTodos()
        }
    }

    func toggleTodo(id: Int64) {
        let ctx = coreData.newBackgroundContext()
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            ctx.performAndWait {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.predicate = NSPredicate(format: "id == %lld", id)
                if let obj = try? ctx.fetch(request).first {
                    obj.isCompleted.toggle()
                    try? ctx.save()
                }
            }
            self.fetchTodos()
        }
    }

    func persistNewTodo(_ todo: TodoItem) {
        backgroundQueue.async { [weak self] in
            self?.store([todo])
            self?.fetchTodos()
        }
    }

    func persistEditedTodo(_ todo: TodoItem) {
        let ctx = coreData.newBackgroundContext()
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            ctx.performAndWait {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.predicate = NSPredicate(format: "id == %lld", todo.id)
                let obj = (try? ctx.fetch(request).first) ?? TodoItemMO(context: ctx)
                obj.populate(from: todo)
                try? ctx.save()
            }
            self.fetchTodos()
        }
    }

    private func store(_ todos: [TodoItem]) {
        let ctx = coreData.newBackgroundContext()
        ctx.performAndWait {
            for todo in todos {
                let request = NSFetchRequest<TodoItemMO>(entityName: "TodoItemMO")
                request.predicate = NSPredicate(format: "id == %lld", todo.id)
                let obj = (try? ctx.fetch(request).first) ?? TodoItemMO(context: ctx)
                obj.populate(from: todo)
            }
            try? ctx.save()
        }
    }
}
