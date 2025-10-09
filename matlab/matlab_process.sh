#!/bin/bash
# MATLAB-style mathematical processing

if [ -f /tmp/keyword.txt ] && [ -f /tmp/target.txt ]; then
  KEYWORD=$(cat /tmp/keyword.txt)
  TARGET=$(cat /tmp/target.txt)
  RESULT=$(cat /tmp/result.txt)

  # Mathematical analysis using bc calculator
  KEYWORD_LEN=${#KEYWORD}
  TARGET_LEN=${#TARGET}

  # Calculate mean length
  MEAN=$(echo "scale=2; ($KEYWORD_LEN + $TARGET_LEN) / 2" | bc)

  # Calculate ASCII sum of keyword
  ASCII_SUM=0
  for (( i=0; i<${#KEYWORD}; i++ )); do
    CHAR="${KEYWORD:$i:1}"
    ASCII_VAL=$(printf "%d" "'$CHAR")
    ASCII_SUM=$((ASCII_SUM + ASCII_VAL))
  done

  # Calculate mean ASCII value
  if [ $KEYWORD_LEN -gt 0 ]; then
    MEAN_ASCII=$(echo "scale=2; $ASCII_SUM / $KEYWORD_LEN" | bc)
  else
    MEAN_ASCII=0
  fi

  # Log MATLAB-style analysis
  echo "=== MATLAB Analysis Report ===" >&2
  echo "Keyword: $KEYWORD (length: $KEYWORD_LEN)" >&2
  echo "Target: $TARGET (length: $TARGET_LEN)" >&2
  echo "Mean length: $MEAN" >&2
  echo "ASCII sum: $ASCII_SUM" >&2
  echo "Mean ASCII: $MEAN_ASCII" >&2
  echo "Search result: $RESULT" >&2
  echo "==============================" >&2
fi