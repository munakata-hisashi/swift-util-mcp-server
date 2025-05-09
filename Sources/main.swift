import MCP
import Foundation
// Initialize the server with capabilities
let server = Server(
    name: "MyServer",
    version: "1.0.0",
    capabilities: .init(
        prompts: .init(listChanged: true),
        resources: .init(
            subscribe: true, listChanged: true
        ),
        tools: .init(listChanged: true)
    )
)

// Create transport and start server
let transport = StdioTransport()
try await server.start(transport: transport)

// Register method handlers
await server.withMethodHandler(ListTools.self) { params in
    // Handle resource read request

    let tools = [
        Tool(
            name: "unixtimeConverter",
            description: "Convert between Unix timestamp and human-readable date",
            inputSchema: .object([
                "date": .string("Human readable date formatted by yyyy-MM-dd HH:mm:ss")
            ])
        )
    ]
    return .init(tools: tools)
}

await server.withMethodHandler(CallTool.self) { params in
    switch params.name {
        case "unixtimeConverter":
        let dateStr = params.arguments?["date"]?.stringValue ?? "Unknown"
        // Convert date to Unix timestamp
        let formatter = DateFormatter()
        let format: String = "yyyy-MM-dd HH:mm:ss"
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
                    
        guard let date = formatter.date(from: dateStr) else {
            return .init(content: [.text("Invalid date: \(dateStr). Expected format: \(format)")], isError: true)
        }
                    
        let timestamp = date.timeIntervalSince1970
        return .init(content: [.text("Unix timestamp for \(dateStr) is:\(timestamp)")], isError: false)
    default:
        return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
    }
}

await server.waitUntilCompleted()
