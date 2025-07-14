#!/usr/bin/env node

import { gitHubReporter } from './src/mastra/agents/github-reporter/github-reporter.js';

async function testAgent() {
    console.log('🧪 Testing GitHub Reporter Agent...\n');
    
    try {
        console.log('🔍 Testing basic repository analysis...');
        
        // Test a simple request
        const messages = [{
            role: 'user',
            content: 'Give me basic stats for octocat/Hello-World'
        }];
        
        const response = await gitHubReporter.generate(messages);
        
        console.log('✅ Agent Response:');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log(response.text);
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        if (response.toolResults && response.toolResults.length > 0) {
            console.log('🛠️ Tools used:', response.toolResults.length);
            response.toolResults.forEach((result, index) => {
                console.log(`   ${index + 1}. ${result.toolName}`);
            });
        }
        
        console.log('\n🎉 Test completed successfully!');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
    }
}

testAgent();
