#!/usr/bin/env node

/**
 * RHYTHM Method Documentation - Link Validator
 * 
 * Validates all internal links in markdown files to ensure:
 * 1. Referenced files exist
 * 2. Anchor links point to valid headings
 * 3. No broken cross-references
 */

const fs = require('fs');
const path = require('path');

// Configuration
const DOCS_DIR = path.join(__dirname, '..');
const IGNORE_PATTERNS = [
    'node_modules',
    '.baton',
    '.claude',
    '.cursor',
    '.gemini',
    '.git',
    '_repository_review.md'
];

// Results tracking
let totalLinks = 0;
let brokenLinks = 0;
const errors = [];

/**
 * Check if path should be ignored
 */
function shouldIgnore(filePath) {
    return IGNORE_PATTERNS.some(pattern => filePath.includes(pattern));
}

/**
 * Get all markdown files recursively
 */
function getMarkdownFiles(dir) {
    const files = [];

    function traverse(currentDir) {
        const items = fs.readdirSync(currentDir);

        for (const item of items) {
            const fullPath = path.join(currentDir, item);

            if (shouldIgnore(fullPath)) continue;

            const stat = fs.statSync(fullPath);

            if (stat.isDirectory()) {
                traverse(fullPath);
            } else if (item.endsWith('.md')) {
                files.push(fullPath);
            }
        }
    }

    traverse(dir);
    return files;
}

/**
 * Extract all markdown links from content
 */
function extractLinks(content, filePath) {
    const links = [];

    // Match [text](link) and [text](link#anchor)
    const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
    let match;

    while ((match = linkRegex.exec(content)) !== null) {
        const linkText = match[1];
        const linkUrl = match[2];

        // Skip external links (http://, https://, mailto:, etc.)
        if (linkUrl.match(/^(https?:|mailto:|ftp:)/i)) {
            continue;
        }

        // Skip file:// links (used in artifacts)
        if (linkUrl.startsWith('file://')) {
            continue;
        }

        links.push({
            text: linkText,
            url: linkUrl,
            line: content.substring(0, match.index).split('\n').length
        });
    }

    return links;
}

/**
 * Extract all headings from markdown content
 */
function extractHeadings(content) {
    const headings = [];
    const lines = content.split('\n');

    for (const line of lines) {
        const match = line.match(/^(#{1,6})\s+(.+)$/);
        if (match) {
            const heading = match[2].trim();
            // Convert heading to anchor format (lowercase, replace spaces with hyphens, remove special chars)
            const anchor = heading
                .toLowerCase()
                .replace(/[^\w\s-]/g, '')
                .replace(/\s+/g, '-');
            headings.push(anchor);
        }
    }

    return headings;
}

/**
 * Validate a single link
 */
function validateLink(link, sourceFile, sourceDir) {
    totalLinks++;

    const { url, text, line } = link;

    // Split URL into file path and anchor
    const [filePath, anchor] = url.split('#');

    // Resolve the target file path
    let targetFile;
    if (filePath) {
        targetFile = path.resolve(sourceDir, filePath);
    } else {
        // Same file anchor link
        targetFile = sourceFile;
    }

    // Check if file exists
    if (!fs.existsSync(targetFile)) {
        brokenLinks++;
        errors.push({
            file: path.relative(DOCS_DIR, sourceFile),
            line,
            error: `Broken link: "${text}" -> ${url}`,
            reason: `File not found: ${path.relative(DOCS_DIR, targetFile)}`
        });
        return;
    }

    // If there's an anchor, validate it exists in the target file
    if (anchor) {
        const targetContent = fs.readFileSync(targetFile, 'utf-8');
        const headings = extractHeadings(targetContent);

        if (!headings.includes(anchor)) {
            brokenLinks++;
            errors.push({
                file: path.relative(DOCS_DIR, sourceFile),
                line,
                error: `Broken anchor: "${text}" -> ${url}`,
                reason: `Anchor "#${anchor}" not found in ${path.relative(DOCS_DIR, targetFile)}`
            });
        }
    }
}

/**
 * Validate all links in a file
 */
function validateFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const links = extractLinks(content, filePath);
    const sourceDir = path.dirname(filePath);

    for (const link of links) {
        validateLink(link, filePath, sourceDir);
    }
}

/**
 * Main validation function
 */
function main() {
    console.log('🔍 RHYTHM Method Documentation - Link Validator\n');
    console.log('Scanning for markdown files...');

    const files = getMarkdownFiles(DOCS_DIR);
    console.log(`Found ${files.length} markdown files\n`);

    console.log('Validating links...');
    for (const file of files) {
        validateFile(file);
    }

    console.log('\n' + '='.repeat(60));
    console.log('VALIDATION RESULTS');
    console.log('='.repeat(60) + '\n');

    console.log(`Total links checked: ${totalLinks}`);
    console.log(`Broken links found: ${brokenLinks}\n`);

    if (errors.length > 0) {
        console.log('❌ ERRORS FOUND:\n');

        // Group errors by file
        const errorsByFile = {};
        for (const error of errors) {
            if (!errorsByFile[error.file]) {
                errorsByFile[error.file] = [];
            }
            errorsByFile[error.file].push(error);
        }

        for (const [file, fileErrors] of Object.entries(errorsByFile)) {
            console.log(`📄 ${file}`);
            for (const error of fileErrors) {
                console.log(`   Line ${error.line}: ${error.error}`);
                console.log(`   → ${error.reason}\n`);
            }
        }

        console.log('='.repeat(60));
        process.exit(1);
    } else {
        console.log('✅ All links are valid!\n');
        console.log('='.repeat(60));
        process.exit(0);
    }
}

// Run validation
main();
