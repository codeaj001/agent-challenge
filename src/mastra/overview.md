Memory overview
Memory is how agents manage the context that’s available to them, it’s a condensation of all chat messages into their context window.

The Context Window
The context window is the total information visible to the language model at any given time.

In Mastra, context is broken up into three parts: system instructions and information about the user (working memory), recent messages (message history), and older messages that are relevant to the user’s query (semantic recall).

Working memory can persist at different scopes - either per conversation thread (default) or across all threads for the same user (resource-scoped), enabling persistent user profiles that remember context across conversations.

In addition, we provide memory processors to trim context or remove information if the context is too long.

Quick Start
The fastest way to see memory in action is using the built-in development playground.

If you haven’t already, create a new Mastra project following the main Getting Started guide.

1. Install the memory package:


pnpm add @mastra/memory@latest
2. Create an agent and attach a Memory instance:

src/mastra/agents/index.ts
import { Agent } from "@mastra/core/agent";
import { Memory } from "@mastra/memory";
import { openai } from "@ai-sdk/openai";
import { LibSQLStore } from "@mastra/libsql";
 
// Initialize memory with LibSQLStore for persistence
const memory = new Memory({
  storage: new LibSQLStore({
    url: "file:../mastra.db", // Or your database URL
  }),
});
 
export const myMemoryAgent = new Agent({
  name: "MemoryAgent",
  instructions: "...",
  model: openai("gpt-4o"),
  memory,
});
3. Start the Development Server:


pnpm run dev
4. Open the playground (http://localhost:4111 ) and select your MemoryAgent:

Send a few messages and notice that it remembers information across turns:

➡️ You: My favorite color is blue.
⬅️ Agent: Got it! I'll remember that your favorite color is blue.
➡️ You: What is my favorite color?
⬅️ Agent: Your favorite color is blue.
Memory Threads
Mastra organizes memory into threads, which are records that identify specific conversation histories, using two identifiers:

threadId: A specific conversation id (e.g., support_123).
resourceId: The user or entity id that owns each thread (e.g., user_123, org_456).
The resourceId is particularly important for resource-scoped working memory, which allows memory to persist across all conversation threads for the same user.

const response = await myMemoryAgent.stream("Hello, my name is Alice.", {
  resourceId: "user_alice",
  threadId: "conversation_123",
});
Important: without these ID’s your agent will not use memory, even if memory is properly configured. The playground handles this for you, but you need to add ID’s yourself when using memory in your application.

Thread Title Generation
Mastra can automatically generate meaningful titles for conversation threads based on the user’s first message. This helps organize and identify conversations in your application UI.

const memory = new Memory({
  options: {
    threads: {
      generateTitle: true, // Enable automatic title generation
    },
  },
});
By default, title generation uses the same model and default instructions as your agent. For customization or cost optimization, you can specify a different model or provide custom instructions specifically for title generation:

const memory = new Memory({
  options: {
    threads: {
      generateTitle: {
        model: openai("gpt-4.1-nano"), // Use cheaper model for titles
        instructions: "Generate a concise title for this conversation based on the first user message.",
      },
    },
  },
});
Title generation happens asynchronously after the agent responds, so it doesn’t impact response time. See the full configuration reference for more details and examples.

Conversation History
By default, the Memory instance includes the last 10 messages from the current Memory thread in each new request. This provides the agent with immediate conversational context.

const memory = new Memory({
  options: {
    lastMessages: 10,
  },
});
Important: Only send the newest user message in each agent call. Mastra handles retrieving and injecting the necessary history. Sending the full history yourself will cause duplication. See the AI SDK Memory Example for how to handle this with when using the useChat frontend hooks.

Storage Configuration
Conversation history relies on a storage adapter to store messages. By default it uses the same storage provided to the main Mastra instance 

If neither the Memory instance nor the Mastra object specify a storage provider, Mastra will not persist memory data across application restarts or deployments. For any deployment beyond local testing you should provide your own storage configuration either on Mastra or directly within new Memory().

When storage is given on the Mastra instance it will automatically be used by every Memory attached to agents. In that case you do not need to pass storage to new Memory() unless you want a per-agent override.

import { Memory } from "@mastra/memory";
import { Agent } from "@mastra/core/agent";
import { LibSQLStore } from "@mastra/libsql";
 
const agent = new Agent({
  memory: new Memory({
    storage: new LibSQLStore({
      url: "file:./local.db",
    }),
  }),
});
Storage code Examples:

LibSQL
Postgres
Upstash
Next Steps
Now that you understand the core concepts, continue to semantic recall to learn how to add RAG memory to your Mastra agents.

Alternatively you can visit the configuration reference for available options, or browse usage examples.