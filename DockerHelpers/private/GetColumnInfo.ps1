function GetColumnInfo($headerRow){
    $lastIndex = 0
    $i = 0
    while ($i -lt $headerRow.Length){
        $i = GetHeaderBreak $headerRow $lastIndex
        if ($i -lt 0){
            $name = $headerRow.Substring($lastIndex)
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start=$lastIndex; End=-1}
            break
        } else {
            $name = $headerRow.Substring($lastIndex, $i-$lastIndex)
            $temp = $lastIndex
            $lastIndex = GetHeaderNonBreak $headerRow $i
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start=$temp; End=$lastIndex}
       }
    }
}