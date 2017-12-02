import Vapor
import FluentProvider
import HTTP

// MARK: - Job model
final class Job: Model {
    let storage = Storage()

    var name: String
    var status: String

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let status = "status"
    }

    init(name: String, status: String) {
        self.name = name
        self.status = status    
    }

    init(row: Row) throws {
        name = try row.get(Job.Keys.name)
        status = try row.get(Job.Keys.status)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Job.Keys.name, name)
        try row.set(Job.Keys.status, status)

        return row
    }
}

// MARK: - Preparation
extension Job: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Job.Keys.name)
            builder.string(Job.Keys.status)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension Job: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Job.Keys.name),
            status: try json.get(Job.Keys.status)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Job.Keys.id, id)
        try json.set(Job.Keys.name, name)
        try json.set(Job.Keys.status, status)

        return json
    }
}

// MARK: HTTP
extension Job: ResponseRepresentable { }

// MARK: Update
extension Job: Updateable {
    public static var updateableKeys: [UpdateableKey<Job>] {
        return [
            UpdateableKey(Job.Keys.name, String.self) { job, name in
                job.name = name
            },
            UpdateableKey(Job.Keys.status, String.self) { job, status in
                job.status = status
            }
        ]
    }
}
