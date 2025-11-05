import fs from 'node:fs';
import path from 'node:path';

interface McpServer {
    type: string;
    url: string;
    headers?: {
        Authorization: string;
    };
}

interface McpConfig {
    mcpServers: {
        [key: string]: McpServer;
    };
}

const generateMcpConfig = () => {
    // Load environment variables from .env file if it exists
    const envPath = path.join(__dirname, '..', '.env');
    if (fs.existsSync(envPath)) {
        const envContent = fs.readFileSync(envPath, 'utf8');
        for (const line of envContent.split('\n')) {
            const trimmed = line.trim();
            if (trimmed && !trimmed.startsWith('#')) {
                const [key, ...valueParts] = trimmed.split('=');
                if (key && valueParts.length > 0) {
                    const value = valueParts.join('=').trim();
                    process.env[key.trim()] = value;
                }
            }
        }
    }

    // Read template from .mcp.template.json
    const templatePath = path.join(__dirname, '..', '.mcp.template.json');
    if (!fs.existsSync(templatePath)) {
        throw new Error('.mcp.template.json not found');
    }

    const templateContent = fs.readFileSync(templatePath, 'utf8');

    // Extract all environment variable references from the template
    const envVarMatches = templateContent.matchAll(/\$\{([^}]+)\}/g);
    const requiredEnvVars = new Set<string>();
    for (const match of envVarMatches) {
        requiredEnvVars.add(match[1]);
    }

    // Check for missing environment variables
    const missingVars: string[] = [];
    for (const varName of requiredEnvVars) {
        if (!process.env[varName]) {
            missingVars.push(varName);
        }
    }

    // Substitute environment variables in the template
    const configContent = templateContent.replace(/\$\{([^}]+)\}/g, (_match, varName) => {
        return process.env[varName] || '';
    });

    const mcpConfig: McpConfig = JSON.parse(configContent);

    // Write the config file
    const outputPath = path.join(__dirname, '..', '.mcp.json');
    fs.writeFileSync(outputPath, JSON.stringify(mcpConfig, null, 4));

    // biome-ignore lint/suspicious/noConsole: Script output
    console.log('✅ Generated .mcp.json with environment variables');

    // Warn if required env vars are missing
    if (missingVars.length > 0) {
        // biome-ignore lint/suspicious/noConsole: Script warning
        console.warn(`⚠️  Missing environment variables: ${missingVars.join(', ')}`);
        // biome-ignore lint/suspicious/noConsole: Script warning
        console.warn('   Create a .env file with the missing variables');
    }
};

generateMcpConfig();
