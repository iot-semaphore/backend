import Vapor
import HTTP

final class JobController: ResourceRepresentable {
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Job.all().makeJSON()
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort.badRequest
        }

        guard let name = json["name"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "Missing 'name' parameter")
        }
        
        guard let status = json["status"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "Missing 'status' parameter")
        }
        
        let query = try Job.makeQuery()
        guard let job = try query.filter("name", name).first() else {
            let newJob = try request.job()
            try newJob.save()
            
            return newJob
        }
        
        job.status = status
        try job.save()
        
        return job
    }

    func makeResource() -> Resource<Job> {
        return Resource(
            index: index,
            store: store
        )
    }
}

extension Request {
    func job() throws -> Job {
        guard let json = json else { throw Abort.badRequest }
        return try Job(json: json)
    }
}

extension JobController: EmptyInitializable {}
