#!/usr/bin/env node

import { createInterface } from 'readline';
import { gitHubReporter } from './mastra/agents/github-reporter/github-reporter';

const rl = createInterface({
    input: process.stdin,
    output: process.stdout,
});

console.log(`
🚀 GitHub Reporter CLI - Enhanced Edition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Welcome! I provide comprehensive GitHub repository analysis with unique insights.

📊 **Basic Analysis:**
• "Report on octocat/Hello-World"
• "Analyze microsoft/vscode"
• "Give me stats for facebook/react"

🌟 **Enhanced Features:**
🛡️  "Bus factor analysis for nodejs/node"
🔍 "Code similarity check for facebook/react"
🕒 "Timeline visualization for microsoft/vscode"
💾 "Compare my previous analysis of tensorflow/tensorflow"

🚀 **NEW MIND-BLOWING FEATURES:**
🎯 "Predict the future of kubernetes/kubernetes"
🕸️ "Map the ecosystem of facebook/react"
🎨 "Generate dashboard for microsoft/vscode"
🔮 "AI health prediction for pytorch/pytorch"

🎯 **LEGENDARY Analysis:**
• "Ultimate analysis of kubernetes/kubernetes"
• "Complete ecosystem deep dive into pytorch/pytorch"
• "Mind-blowing report on vercel/next.js with predictions"
• "Create beautiful dashboard for tensorflow/tensorflow"

Type 'exit' to quit.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);

function showFeatures() {
    console.log(`
🌟 GitHub Reporter - Enhanced Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 **Core Analysis Tools:**
   • Repository Statistics (stars, forks, issues, PRs, languages)
   • Health Scoring (0-100 scale with recommendations)
   • License and maintenance status analysis

🛡️ **Bus Factor Analysis:**
   • Calculate developer dependency risk
   • Identify key contributors and knowledge concentration
   • Risk assessment: CRITICAL → HIGH → MEDIUM → LOW
   • Recommendations for improving team diversity

🔍 **Code Similarity & Risk Detection:**
   • Detect potential code duplication and forks
   • Security risk assessment (sensitive files)
   • Fork activity monitoring
   • Originality verification

🕒 **Contribution Timeline Visualization:**
   • Gource-style timeline generation
   • Development activity analysis
   • Peak activity identification
   • Contributor trend analysis

🚀 **NEW! AI-Powered Health Prediction:**
   • Predict repository future health decay/growth
   • Forecast star growth and contributor trends
   • Calculate maintenance burden scores
   • AI insights with confidence percentages

🕸️ **NEW! Repository Ecosystem Mapping:**
   • Map dependency networks and influence scores
   • Analyze supply chain security risks
   • Identify alternatives and competitive landscape
   • Calculate ecosystem positioning and impact

🎨 **NEW! Interactive Dashboard Generation:**
   • Beautiful ASCII art dashboards and infographics
   • Multiple visualization styles (minimal/detailed/technical)
   • Shareable repository report cards with grades
   • Timeline visualizations and network diagrams

💾 **Memory & Comparison:**
   • Store analysis results for future reference
   • Track repository changes over time
   • Before/after comparisons
   • Trend analysis and insights

🎯 **Example Commands:**
   • "Analyze microsoft/vscode"                    → Basic analysis
   • "Bus factor for nodejs/node"                  → Developer risk
   • "Code similarity check for facebook/react"    → Security analysis
   • "Timeline for kubernetes/kubernetes"          → Activity visualization
   • "Predict the future of tensorflow/tensorflow" → AI health prediction
   • "Map ecosystem of pytorch/pytorch"            → Dependency analysis
   • "Generate dashboard for vercel/next.js"       → Visual dashboard
   • "Ultimate analysis of microsoft/TypeScript"   → ALL features

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);
}

async function handleInput(input: string) {
    const trimmedInput = input.toLowerCase().trim();
    
    if (trimmedInput === 'exit') {
        console.log('👋 Goodbye!');
        process.exit(0);
    }
    
    if (trimmedInput === 'help' || trimmedInput === 'features') {
        showFeatures();
        return;
    }

    if (!input.trim()) {
        console.log('📝 Please enter a command or repository name. Type "help" for available features.');
        return;
    }

    try {
        console.log('\n🔍 Analyzing...\n');
        
        // Create a conversation with the agent
        const messages = [
            {
                role: 'user' as const,
                content: input
            }
        ];

        const response = await gitHubReporter.generate(messages);
        
        console.log('🤖 GitHub Reporter:');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log(response.text);
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        // Log memory updates if any
        if (response.toolResults && response.toolResults.length > 0) {
            console.log('💾 Memory updated with latest report.\n');
        }
        
    } catch (error) {
        console.error('❌ Error:', error instanceof Error ? error.message : String(error));
    }
}

function prompt() {
    rl.question('📝 Your request: ', handleInput);
}

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('\n👋 Goodbye!');
    process.exit(0);
});

// Start the CLI
prompt();
rl.on('line', () => {
    prompt();
});
