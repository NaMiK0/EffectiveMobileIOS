import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    static func inMemory() -> CoreDataStack {
        let stack = CoreDataStack()
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        stack._storeDescriptions = [description]
        return stack
    }

    private var _storeDescriptions: [NSPersistentStoreDescription]?
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "TodoModel",
            managedObjectModel: CoreDataStack.makeModel()
        )
        if let descriptions = _storeDescriptions {
            container.persistentStoreDescriptions = descriptions
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData load error: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "TodoItemMO"
        entity.managedObjectClassName = NSStringFromClass(TodoItemMO.self)

        entity.properties = [
            makeAttr("id",          .integer64AttributeType),
            makeAttr("title",       .stringAttributeType,  optional: true),
            makeAttr("desc",        .stringAttributeType,  optional: true),
            makeAttr("createdAt",   .dateAttributeType,    optional: true),
            makeAttr("isCompleted", .booleanAttributeType, defaultValue: false)
        ]
        model.entities = [entity]
        return model
    }

    private static func makeAttr(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = optional
        if let dv = defaultValue { attr.defaultValue = dv }
        return attr
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        try? save()
    }
}

@objc(TodoItemMO)
class TodoItemMO: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var createdAt: Date?
    @NSManaged var isCompleted: Bool
}

extension TodoItemMO {
    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            title: title ?? "",
            description: desc ?? "",
            createdAt: createdAt ?? Date(),
            isCompleted: isCompleted
        )
    }

    func populate(from item: TodoItem) {
        id = item.id
        title = item.title
        desc = item.description
        createdAt = item.createdAt
        isCompleted = item.isCompleted
    }
}
