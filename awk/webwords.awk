#!/usr/bin/awk -f

# AWK WebWords Text Processing Implementation
# Demonstrates AWK's powerful text processing capabilities for keyword search

# AWK text analysis function - this is what AWK excels at!
function analyze_text_with_awk(search_keyword, text_content,    
                               matches, positions, line_count, word_count, 
                               char_count, i, line, words, match_line, result_summary) {
    
    print "AWK: Starting advanced text analysis..." > "/dev/stderr"
    
    # Convert to lowercase for case-insensitive search
    search_keyword = tolower(search_keyword)
    text_content = tolower(text_content)
    
    # Initialize counters
    matches = 0
    positions = ""
    line_count = 0
    word_count = 0
    char_count = length(text_content)
    
    # AWK's strength: line-by-line text processing
    split(text_content, lines, "\n")
    
    for (i = 1; i <= length(lines); i++) {
        line = lines[i]
        line_count++
        
        # Count words in this line
        split(line, words, /[ \t]+/)
        word_count += length(words)
        
        # Check for keyword matches in this line using AWK's index() function
        pos = index(line, search_keyword)
        if (pos > 0) {
            matches++
            if (positions == "") {
                positions = "line" i ":col" pos
            } else {
                positions = positions ", line" i ":col" pos
            }
            match_line = i
        }
    }
    
    # AWK statistical analysis
    avg_line_length = (line_count > 0) ? char_count / line_count : 0
    keyword_density = (char_count > 0) ? (length(search_keyword) * matches / char_count) * 100 : 0
    
    # Print detailed AWK analysis
    print "AWK Text Processing Results:" > "/dev/stderr"
    print "  Text statistics:" > "/dev/stderr"
    printf "    Total characters: %d\n", char_count > "/dev/stderr"
    printf "    Total lines: %d\n", line_count > "/dev/stderr"
    printf "    Total words: %d\n", word_count > "/dev/stderr"
    printf "    Average line length: %.2f\n", avg_line_length > "/dev/stderr"
    
    print "  Search results:" > "/dev/stderr"
    printf "    Keyword: '%s'\n", search_keyword > "/dev/stderr"
    printf "    Matches found: %d\n", matches > "/dev/stderr"
    printf "    Keyword density: %.4f%%\n", keyword_density > "/dev/stderr"
    
    if (matches > 0) {
        printf "    Match positions: %s\n", positions > "/dev/stderr"
        print "AWK: Keyword FOUND using AWK text processing!" > "/dev/stderr"
        return "true"
    } else {
        print "AWK: Keyword NOT FOUND after AWK analysis" > "/dev/stderr"
        return "false"
    }
}

# Main entry point for AWK processing
# This function is called by the wrapper script
function process_webwords_request() {
    # Read keyword and content from files (set by wrapper)
    keyword_file = "/tmp/awk_keyword.txt"
    content_file = "/tmp/awk_content.txt"
    result_file = "/tmp/awk_result.txt"
    
    # Read keyword
    if ((getline keyword < keyword_file) > 0) {
        close(keyword_file)
    } else {
        print "AWK Error: Cannot read keyword file" > "/dev/stderr"
        print "false" > result_file
        close(result_file)
        return
    }
    
    # Read content (AWK handles large files efficiently)
    content = ""
    while ((getline line < content_file) > 0) {
        content = content line "\n"
    }
    close(content_file)
    
    if (content == "") {
        print "AWK Error: Cannot read content file" > "/dev/stderr"
        print "false" > result_file
        close(result_file)
        return
    }
    
    # Use AWK's text processing power
    result = analyze_text_with_awk(keyword, content)
    
    # Write result
    print result > result_file
    close(result_file)
    
    print "AWK: Processing complete, result = " result > "/dev/stderr"
}

# When called as a script, process the webwords request
BEGIN {
    process_webwords_request()
    exit
}

# Function to parse query parameters (if processing real HTTP requests)
function parse_query(query_string,    params, pairs, i, kv) {
    delete params
    
    # Split by & to get key=value pairs
    split(query_string, pairs, "&")
    
    for (i in pairs) {
        if (split(pairs[i], kv, "=") == 2) {
            params[kv[1]] = kv[2]
        }
    }
    
    return length(params)
}

# Function to URL decode (basic implementation)
function url_decode(str,    result, i, c, hex) {
    result = ""
    
    for (i = 1; i <= length(str); i++) {
        c = substr(str, i, 1)
        
        if (c == "%") {
            hex = substr(str, i+1, 2)
            # Convert hex to character (simplified)
            if (hex == "20") c = " "
            else if (hex == "2F") c = "/"
            else if (hex == "3D") c = "="
            i += 2
        } else if (c == "+") {
            c = " "
        }
        
        result = result c
    }
    
    return result
}