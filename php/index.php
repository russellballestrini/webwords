<?php
$keyword = $_GET['keyword'] ?? '';
$target = $_GET['target'] ?? '';
$found = 'false';

if (!empty($keyword) && !empty($target)) {
    $context = stream_context_create([
        'http' => [
            'timeout' => 10
        ]
    ]);
    
    $body = @file_get_contents($target, false, $context);
    
    if ($body !== false && strpos($body, $keyword) !== false) {
        $found = 'true';
    }
    
    error_log("found=$found, keyword=$keyword, uri=$target");
}

echo $found;
?>