import Async
import Foundation

/// An HTTP response.
///
/// Used to respond to a request from an HTTP client.
///
///     200 OK HTTP/1.1
///     Content-Length: 5
///
///     hello
///
/// The HTTP server will stream incoming requests from clients.
/// You must handle these requests and generate responses.
///
/// When you want to request data from another server, such as
/// calling another API from your application, you will create
/// a request and use the HTTP client to prompt a response
/// from the remote server.
///
///     let res = Response(status: .ok, body: "hello")
///
/// [Learn More →](https://docs.vapor.codes/3.0/http/response/)
public final class Response: Message {
    /// See Message.version
    public var version: Version

    /// HTTP response status code.
    public var status: Status

    /// See Message.headers
    public var headers: Headers

    /// See Message.body
    public var body: Body

    /// See Extendable.extend
    public var extend: Extend

    /// Create a new HTTP response.
    public init(
        version: Version = Version(major: 1, minor: 1),
        status: Status = .ok,
        headers: Headers = Headers(),
        body: Body = Body()
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.body = body
        self.extend = Extend()
    }
}

extension Response {
    /// Create a new HTTP response using something BodyRepresentable.
    public convenience init(
        version: Version = Version(major: 1, minor: 1),
        status: Status = .ok,
        headers: Headers = Headers(),
        body: BodyRepresentable
    ) throws {
        try self.init(version: version, status: status, headers: headers, body: body.makeBody())
    }
}

/// Can be converted from a response.
///
/// [Learn More →](https://docs.vapor.codes/3.0/http/response/#responseinitializable)
public protocol ResponseDecodable {
    static func decode(from res: Response, for req: Request) throws -> Future<Self>
}

/// Can be converted to a response
///
/// [Learn More →](https://docs.vapor.codes/3.0/http/response/#responserepresentable)
public protocol ResponseEncodable {
    /// Makes a response using the context provided by the Request
    func encode(to res: inout Response, for req: Request) throws -> Future<Void>
}

/// Can be converted from and to a response
public typealias ResponseCodable = ResponseDecodable & ResponseEncodable

// MARK: Response Conformance

extension Response: ResponseEncodable {
    /// See `ResponseRepresentable.makeResponse`
    public func encode(to res: inout Response, for req: Request) throws -> Future<Void> {
        res = self
        return .done
    }
}

/// Makes `Response` a drop-in replacement for `Future<Response>
extension Response: FutureType {
    public typealias Expectation = Response
}