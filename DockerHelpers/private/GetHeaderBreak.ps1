function GetHeaderBreak($headerRow, $startPoint=0){
    $i = $startPoint
    while( $i + 1  -lt $headerRow.Length)
    {
        if ($headerRow[$i] -eq ' ' -and $headerRow[$i+1] -eq ' '){
            return $i
            break
        }
        $i += 1
    }
    return -1
}