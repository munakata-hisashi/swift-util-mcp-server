import MCP

// Initialize the server with capabilities
let server = Server(
    name: "MyServer",
    version: "1.0.0",
    capabilities: .init(
        prompts: .init(),
        resources: .init(
            subscribe: true
        ),
        tools: .init()
    )
)

// Create transport and start server
let transport = StdioTransport()
try await server.start(transport: transport)

struct InputSchema: Codable {
    var type: String = "object"
    var properties = ["time": ["type": "string"]]
}

let i = InputSchema()

let hoho = try Value.init(i)

print("\(hoho)")

// Register method handlers
await server.withMethodHandler(ListTools.self) { params in
    // Handle resource read request

    return ListTools.Result(
        tools: [
            Tool(
                name: "unixtimeConverter",
                description: "Convert between Unix timestamp and human-readable date",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "time": .object(["type": .string("string")])
                    ]),
                    "required": .array([])
                ])
            )
        ]
    )
}

await server.withMethodHandler(CallTool.self) { params in
    if params.name == "unixtimeConverter" {
        
    }
    
    return CallTool.Result(
        content: [.text("Tool not found or service not enabled: \(params.name) ")],
        isError: true
    )
}

// Stop the server when done
await server.stop()
