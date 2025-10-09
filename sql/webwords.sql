-- SQLite WebWords Database Schema and Keyword Search Functions
-- This script demonstrates actual SQL-based text processing and search capabilities

-- Create a table to store web content for analysis
CREATE TABLE IF NOT EXISTS web_content (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url TEXT NOT NULL,
    content TEXT NOT NULL,
    content_length INTEGER,
    word_count INTEGER,
    processed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create a table to store search results with detailed analysis
CREATE TABLE IF NOT EXISTS search_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content_id INTEGER,
    keyword TEXT NOT NULL,
    found BOOLEAN NOT NULL,
    match_count INTEGER DEFAULT 0,
    match_positions TEXT,
    content_preview TEXT,
    search_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_id) REFERENCES web_content(id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_search_keyword ON search_results(keyword);
CREATE INDEX IF NOT EXISTS idx_content_url ON web_content(url);
CREATE INDEX IF NOT EXISTS idx_search_found ON search_results(found);

-- SQL View: Search statistics
CREATE VIEW IF NOT EXISTS search_statistics AS
SELECT 
    keyword,
    COUNT(*) as total_searches,
    SUM(CASE WHEN found = 1 THEN 1 ELSE 0 END) as successful_searches,
    AVG(match_count) as avg_matches,
    MAX(search_timestamp) as last_search
FROM search_results
GROUP BY keyword;

-- This file serves as the schema definition
-- Actual search queries will be generated dynamically by the wrapper script
-- The wrapper will use SQL operations like:
-- 1. INSERT content into web_content table  
-- 2. Perform keyword search using SQL INSTR() function
-- 3. Calculate match statistics using SQL aggregate functions
-- 4. INSERT search results into search_results table
-- 5. Return the search result using SQL SELECT