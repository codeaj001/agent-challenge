import { Mastra } from "@mastra/core/mastra";
import { PinoLogger } from "@mastra/loggers";
import { gitHubReporter } from "./agents/github-reporter/github-reporter";

console.log("🚀 Initializing GitHub Reporter Agent...");
console.log("📝 Old agents (weather, your-agent) have been removed.");
console.log("✅ Hello, I'm GitHub Reporter. Ask me about any GitHub repository!");

export const mastra = new Mastra({
	agents: { gitHubReporter },
	logger: new PinoLogger({
		name: "GitHubReporter",
		level: "info",
	}),
	server: {
		port: 8080,
		timeout: 30000, // Increased timeout for GitHub API calls
	},
});
