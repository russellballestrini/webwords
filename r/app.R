# R Statistical WebWords Implementation
# Advanced text analysis using R's statistical computing capabilities

# Function to perform statistical text analysis
analyze_text_statistics <- function(keyword, text_content) {
  # Convert to lowercase for case-insensitive search
  keyword_lower <- tolower(keyword)
  text_lower <- tolower(text_content)
  
  # R statistical text analysis
  cat("R Statistical Analysis:\n", file = stderr())
  
  # Text statistics
  text_chars <- nchar(text_content)
  text_words <- length(strsplit(text_content, "\\s+")[[1]])
  keyword_chars <- nchar(keyword)
  
  cat(sprintf("  Text length: %d characters\n", text_chars), file = stderr())
  cat(sprintf("  Text words: %d words\n", text_words), file = stderr())
  cat(sprintf("  Keyword length: %d characters\n", keyword_chars), file = stderr())
  
  # Find all occurrences using R's pattern matching
  matches <- gregexpr(keyword_lower, text_lower, fixed = TRUE)[[1]]
  
  if (matches[1] != -1) {
    # Found matches - perform statistical analysis
    num_matches <- length(matches)
    match_density <- num_matches / text_chars * 1000  # matches per 1000 chars
    
    cat(sprintf("  Keyword found: YES\n"), file = stderr())
    cat(sprintf("  Number of matches: %d\n", num_matches), file = stderr())
    cat(sprintf("  Match positions: %s\n", paste(matches, collapse = ", ")), file = stderr())
    cat(sprintf("  Match density: %.3f per 1000 characters\n", match_density), file = stderr())
    
    # Statistical distribution analysis
    if (num_matches > 1) {
      match_distances <- diff(matches)
      cat(sprintf("  Mean distance between matches: %.2f\n", mean(match_distances)), file = stderr())
      cat(sprintf("  Standard deviation of distances: %.2f\n", sd(match_distances)), file = stderr())
    }
    
    return(TRUE)
  } else {
    cat(sprintf("  Keyword found: NO\n"), file = stderr())
    cat(sprintf("  Search efficiency: %.3f%%\n", keyword_chars / text_chars * 100), file = stderr())
    return(FALSE)
  }
}

# Read inputs from file-based communication (similar to MATLAB approach)
tryCatch({
  # Read keyword from file
  if (file.exists("/tmp/keyword.txt")) {
    keyword <- readLines("/tmp/keyword.txt", n = 1, warn = FALSE)
  } else {
    stop("Keyword file not found")
  }
  
  # Read text content from file
  if (file.exists("/tmp/content.txt")) {
    content <- paste(readLines("/tmp/content.txt", warn = FALSE), collapse = "\n")
  } else {
    stop("Content file not found")
  }
  
  cat(sprintf("R: Processing search for keyword '%s'\n", keyword), file = stderr())
  
  # Perform R statistical analysis
  found_result <- analyze_text_statistics(keyword, content)
  
  # Write result to file
  if (found_result) {
    result <- "true"
    cat("R: Result = true\n", file = stderr())
  } else {
    result <- "false"
    cat("R: Result = false\n", file = stderr())
  }
  
  # Write result file
  writeLines(result, "/tmp/r_result.txt")
  
  # Create R data frame for analysis (R-style data structure)
  analysis_df <- data.frame(
    keyword = keyword,
    content_length = nchar(content),
    keyword_length = nchar(keyword),
    found = found_result,
    timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )
  
  # Save R data frame (R-style output)
  save(analysis_df, file = "/tmp/r_analysis.RData")
  cat("R: Analysis saved to r_analysis.RData\n", file = stderr())
  
}, error = function(e) {
  cat(sprintf("R Error: %s\n", e$message), file = stderr())
  # Write error result
  writeLines("false", "/tmp/r_result.txt")
})