const { spawn } = require('child_process');
const path = require('path');

describe('Direct CLI execution', () => {
    let bridgeProcess;
    
    afterEach((done) => {
        if (bridgeProcess) {
            bridgeProcess.kill('SIGTERM');
            bridgeProcess.on('close', () => {
                bridgeProcess = null;
                done();
            });
        } else {
            done();
        }
    });

    test('should start server when bridge.js is run directly', (done) => {
        // Set environment variables for the child process
        const env = {
            ...process.env,
            BRIDGE_PORT: '8086',
            BRIDGE_TARGET_URL: 'http://localhost:9999/v1',
            BRIDGE_DEBUG: 'false'
        };
        
        // Spawn bridge.js as a child process to test direct execution (line 196)
        bridgeProcess = spawn('node', [path.join(__dirname, '../bridge.js')], {
            env,
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        let output = '';
        
        bridgeProcess.stdout.on('data', (data) => {
            output += data.toString();
            
            // Check if server started successfully
            if (output.includes('Gemini-OpenAI Bridge running on port 8086')) {
                expect(output).toContain('Bridge Starting');
                expect(output).toContain('running on port 8086');
                done();
            }
        });
        
        bridgeProcess.stderr.on('data', (data) => {
            console.error('Bridge stderr:', data.toString());
        });
        
        bridgeProcess.on('error', (error) => {
            done(error);
        });
        
        // Set timeout to avoid hanging
        setTimeout(() => {
            if (!bridgeProcess.killed) {
                done(new Error('Bridge process did not start within timeout'));
            }
        }, 5000);
    });

    test('should handle SIGTERM when run directly', (done) => {
        const env = {
            ...process.env,
            BRIDGE_PORT: '8087',
            BRIDGE_TARGET_URL: 'http://localhost:9999/v1'
        };
        
        bridgeProcess = spawn('node', [path.join(__dirname, '../bridge.js')], {
            env,
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        let serverStarted = false;
        let shutdownMessageSeen = false;
        
        bridgeProcess.stdout.on('data', (data) => {
            const output = data.toString();
            
            if (output.includes('running on port 8087') && !serverStarted) {
                serverStarted = true;
                
                // Send SIGTERM to test graceful shutdown (should trigger lines 178-180)
                bridgeProcess.kill('SIGTERM');
            }
            
            // Check for shutdown message (line 178)
            if (output.includes('Shutting down bridge')) {
                shutdownMessageSeen = true;
            }
        });
        
        bridgeProcess.stderr.on('data', (data) => {
            const errorOutput = data.toString();
            // Check for shutdown message in stderr too
            if (errorOutput.includes('Shutting down bridge')) {
                shutdownMessageSeen = true;
            }
        });
        
        bridgeProcess.on('close', (code) => {
            expect(serverStarted).toBe(true);
            expect(code).toBe(0); // Should exit with code 0 (line 180)
            // Note: we may not see the shutdown message if process exits too quickly
            bridgeProcess = null;
            done();
        });
        
        bridgeProcess.on('error', done);
        
        // Fallback timeout
        setTimeout(() => {
            if (bridgeProcess && !bridgeProcess.killed) {
                done(new Error('Process did not respond to SIGTERM'));
            }
        }, 5000);
    });
    
    test('should execute startServer when run as main module', (done) => {
        // This test specifically validates line 196: if (require.main === module) startServer()
        const env = {
            ...process.env,
            BRIDGE_PORT: '8088',
            BRIDGE_TARGET_URL: 'http://localhost:9999/v1'
        };
        
        // Run bridge.js directly to trigger require.main === module condition
        bridgeProcess = spawn('node', [path.join(__dirname, '../bridge.js')], {
            env,
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        let startServerCalled = false;
        
        bridgeProcess.stdout.on('data', (data) => {
            const output = data.toString();
            
            // If we see the server starting output, it means startServer() was called (line 196)
            if (output.includes('Bridge Starting') || output.includes('running on port 8088')) {
                startServerCalled = true;
                
                // Kill the process once we confirm it started
                bridgeProcess.kill('SIGTERM');
            }
        });
        
        bridgeProcess.on('close', () => {
            expect(startServerCalled).toBe(true);
            bridgeProcess = null;
            done();
        });
        
        bridgeProcess.on('error', done);
        
        setTimeout(() => {
            if (!startServerCalled) {
                done(new Error('startServer was not called when bridge.js run directly'));
            }
        }, 3000);
    });
});