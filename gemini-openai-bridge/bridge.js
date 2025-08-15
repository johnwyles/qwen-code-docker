/**
 * Gemini-OpenAI Bridge
 * Minimal implementation to pass tests (TDD Green Phase)
 */

/**
 * Clean and transform Gemini-style request to OpenAI format
 * @param {Object} geminiRequest - The request from qwen-code
 * @returns {Object} - Clean OpenAI-compatible request
 */
function cleanRequest(geminiRequest) {
    // Handle null/undefined requests
    if (!geminiRequest) {
        return {
            model: 'qwen3-coder:latest'
        };
    }

    // Start with a clean request
    const cleaned = {
        model: geminiRequest.model || 'qwen3-coder:latest'
    };

    // Preserve messages
    if (geminiRequest.messages) {
        cleaned.messages = [...geminiRequest.messages];
    }

    // Handle systemInstruction - convert to system message
    if (geminiRequest.systemInstruction && geminiRequest.systemInstruction.parts) {
        const systemContent = geminiRequest.systemInstruction.parts
            .map(part => part.text || '')
            .join('\n');
        
        if (systemContent) {
            // Add system message at the beginning
            if (!cleaned.messages) {
                cleaned.messages = [];
            }
            cleaned.messages.unshift({
                role: 'system',
                content: systemContent
            });
        }
    }

    // Extract temperature from generationConfig or use direct value
    if (geminiRequest.temperature !== undefined) {
        cleaned.temperature = geminiRequest.temperature;
    } else if (geminiRequest.generationConfig && geminiRequest.generationConfig.temperature !== undefined) {
        cleaned.temperature = geminiRequest.generationConfig.temperature;
    }

    // Handle max_tokens with cap for excessive requests
    let maxTokens = geminiRequest.max_tokens;
    if (maxTokens === undefined && geminiRequest.generationConfig) {
        maxTokens = geminiRequest.generationConfig.maxOutputTokens;
    }
    
    if (maxTokens !== undefined) {
        // Cap excessive token requests (qwen-code often requests 200k+)
        cleaned.max_tokens = maxTokens > 100000 ? 4096 : maxTokens;
    }

    // Preserve other OpenAI-compatible fields
    const openaiFields = ['top_p', 'frequency_penalty', 'presence_penalty', 'stream', 'stop', 'n'];
    openaiFields.forEach(field => {
        if (geminiRequest[field] !== undefined) {
            cleaned[field] = geminiRequest[field];
        }
    });

    // NOTE: We intentionally DO NOT copy these Gemini-specific fields:
    // - generationConfig (extracted what we need)
    // - safetySettings (not compatible with OpenAI)
    // - tools (different format)
    // - toolConfig (not compatible)
    // - systemInstruction (converted to message)

    return cleaned;
}

/**
 * Create Express app for the bridge
 * @returns {Object} - Express app instance
 */
function createApp() {
    const express = require('express');
    const app = express();
    
    app.use(express.json({ limit: '50mb' }));
    
    const TARGET_URL = process.env.BRIDGE_TARGET_URL || process.env.OPENAI_BASE_URL;
    
    // Health check endpoint
    app.get('/health', (req, res) => {
        res.json({
            status: 'healthy',
            bridge: 'gemini-openai-bridge',
            target: TARGET_URL,
            uptime: process.uptime()
        });
    });
    
    // Models endpoint - forward as-is
    app.get('/v1/models', async (req, res) => {
        try {
            const response = await fetch(TARGET_URL + '/models', {
                headers: {
                    'Authorization': req.headers.authorization || ''
                }
            });
            
            const data = await response.json();
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: 'Failed to fetch models' });
        }
    });
    
    // Chat completions endpoint - main bridge functionality
    app.post('/v1/chat/completions', async (req, res) => {
        try {
            // Clean the request using our tested function
            const cleanedRequest = cleanRequest(req.body);
            
            // Forward to target server
            const response = await fetch(TARGET_URL + '/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': req.headers.authorization || '',
                    'Accept': req.headers.accept || 'application/json',
                },
                body: JSON.stringify(cleanedRequest)
            });
            
            const data = await response.json();
            res.status(response.status).json(data);
            
        } catch (error) {
            res.status(500).json({
                error: {
                    message: 'Bridge error: ' + error.message,
                    type: 'bridge_error'
                }
            });
        }
    });
    
    return app;
}

/**
 * Start the bridge server
 */
function startServer() {
    const app = createApp();
    const PORT = process.env.BRIDGE_PORT || 8080;
    const TARGET_URL = process.env.BRIDGE_TARGET_URL || process.env.OPENAI_BASE_URL;
    const DEBUG = process.env.BRIDGE_DEBUG === 'true';
    
    console.log('===========================================');
    console.log('Gemini-OpenAI Bridge Starting...');
    console.log(`Bridge Port: ${PORT}`);
    console.log(`Target URL: ${TARGET_URL}`);
    console.log(`Debug Mode: ${DEBUG ? 'ON' : 'OFF'}`);
    console.log('===========================================');
    
    const server = app.listen(PORT, '0.0.0.0', () => {
        console.log(`\n✅ Gemini-OpenAI Bridge running on port ${PORT}`);
        console.log(`📡 Forwarding to: ${TARGET_URL}`);
        console.log('\nWaiting for requests...\n');
    });
    
    // Handle shutdown gracefully
    process.on('SIGTERM', () => {
        console.log('\nShutting down bridge...');
        server.close(() => {
            process.exit(0);
        });
    });
    
    return server;
}

// Export for testing
module.exports = {
    cleanRequest,
    createApp,
    startServer
};

// If this file is run directly, start the server
if (require.main === module) {
    startServer();
}