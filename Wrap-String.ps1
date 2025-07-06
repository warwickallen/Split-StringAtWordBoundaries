<#
.SYNOPSIS
    Wraps a string to a specified maximum length per line, splitting only at designated delimiters.

.DESCRIPTION
    The Wrap-String function breaks a string into multiple lines, ensuring each line does not exceed the specified length.
    It splits the input string at points matching the provided WordDelimiter regular expression, preserving the first capture group (if present) at the split points.
    Lines are joined using the specified LineSeparator, and the function ensures that no line exceeds the specified length (unless that line consists of a single word that is longer than the specified length), accounting for the separator's length.
    The function supports pipeline input for the String parameter.

.PARAMETER String
    The input string to be wrapped. This parameter is required unless -Help, -Test, or -ShowVersion is specified. Can be provided via pipeline.

.PARAMETER Length
    The maximum number of characters per line, excluding the line separator. Defaults to 80.
    Alias: N

.PARAMETER LineSeparator
    The string used to separate lines in the output. Defaults to a newline character ([char]10).
    Alias: Separator

.PARAMETER WordDelimiter
    A regular expression defining where the string can be split. The matching characters are discarded, except for the first capture group (if it exists), used only at line breaks.
    Defaults to '(?:(-)|\s)\s*', i.e., a hyphen (retained) or whitespace (replaced with a single space), followed by any additional whitespace (discarded).
    Aliases: D, Delimiter

.PARAMETER Help
    Displays the help information for the function and exits.

.PARAMETER Test
    Runs predefined test cases to verify the function's behaviour and exits.

.PARAMETER ShowVersion
    Displays the current version of the function and exits.
    Alias: Version

.EXAMPLE
    Wrap-String -String "aaa.bbb...ccc.ddd.eee.fff" -Length 12 -WordDelimiter '(\.)\.*'
    Output:
    aaa.bbb.
    ccc.ddd.eee.
    fff

.EXAMPLE
    Wrap-String -String "This is a long sentence to wrap" -Length 10
    Output:
    This is a
    long
    sentence
    to wrap

.NOTES
    Version: 0.0.11
#>
function Wrap-String {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$String,

        [Alias("N")]
        [Parameter()]
        [int]$Length = 80,

        [Alias("Separator")]
        [Parameter()]
        [string]$LineSeparator = [char]10,

        [Alias("D","Delimiter")]
        [Parameter()]
        [string]$WordDelimiter = '(?:(-)|\s)\s*',

        [Parameter()]
        [switch]$Help,

        [Parameter()]
        [switch]$Test,

        [Alias("Version")]
        [Parameter()]
        [switch]$ShowVersion
    )

    begin {
        $Version = '0.0.11'
        if ($ShowVersion) {
            Write-Output "Wrap-String Version: $Version"
            return
        }
        if ($Help) {
            Get-Help -Name Wrap-String -Full
            return
        }
        if ($Test) {
            Write-Host "Wrap-String Version: $Version"
            Write-Host "Running Wrap-String test cases..."
            Write-Host ""

            $test_number = 0წ

            (
                @{ params = "-String 'aaa.bbb...ccc.ddd.eee.fff' -Length 12 -WordDelimiter '(`.)`.*'"
                   expected = "aaa.bbb.`nccc.ddd.eee.`nfff" },
                @{ params = "-String 'This is a long sentence to wrap' -Length 10"
                   expected = "This is a`nlong`nsentence`nto wrap" },
                @{ params = "-String 'aaa.bbb...cccc.ddd.eee.fff.hhh.iii' -Length 12 -WordDelimiter '(`.)`.*' -LineSeparator ([char]10 + '123')"
                   expected = "aaa.bbb.`n123cccc.ddd.`n123eee.fff.hhh.`n123iii" },
                @{ params = "-Length 98 -String 'The Wrap-String function breaks a string into multiple lines, ensuring each line does not exceed the specified length.' -WordDelimiter '(.) '"
                   expected = "The Wrap-String function breaks a string into multiple lines, ensuring each line does not exceed`nthe specified length." },
                @{ params = "-String 'Mr Wright-Rong has a double-barrelled name.' -Length 12"
                   expected = "Mr Wright-`nRong has a`ndouble-`nbarrelled`nname." },
                @{ params = "-String '. a.bb cc.ddd eee.ffff gggg.hhh iii.jj kk.l . ' -Length 8 -WordDelimiter '`.'"
                   expected = ". a`nbb cc`nddd eee`nffff gggg`nhhh iii`njj kk`nl . " }
            ) | ForEach-Object {
                $test_number++
                $params = $_.params
                $expected = $_.expected
                Write-Host "Test ${test_number}:`nWrap-String $params"
                $expected_formatted = [regex]::Replace($expected, '(?m)(^|$)', '~')
                Write-Host )]
                $actual = Invoke-Expression "Wrap-String $params"
                $success = ($actual -eq $expected)
                Write-Host "Expected result:`n$expected_formatted"
                if ($success) {
                    Write-Host -ForegroundColor Green 'PASS'
                } else {
                    Write-Host -ForegroundColor Red 'FAIL'
                    $actual_formatted = [regex]::Replace($actual, '(?m)(^|$)', '~')
                    Write-Host "Actual result:`n$actual_formatted"
                }
                Write-Host ""
            }
            return
        }
    }

    process {
        $tokens = @()
        $pattern = $WordDelimiter
        $inputStr = $String

        # Build tokens preserving first capture group
        $lastIndex = 0
        $matches = [regex]::Matches($inputStr, $pattern)
        foreach ($match in $matches) {
            $start = $match.Index
            $length = $match.Length
            $fragment = $inputStr.Substring($lastIndex, $start - $lastIndex)
            if ($fragment -ne "") { $tokens += $fragment }
            if ($match.Groups.Count -gt 1 -and $match.Groups[1].Value -ne "") {
                $tokens += $match.Groups[1].Value
            }
            $lastIndex = $start + $length
        }
        # Add the trailing fragment
        if ($lastIndex -lt $inputStr.Length) {
            $tokens += $inputStr.Substring($lastIndex)
        }

        # Now wrap into lines
        $lines = @()
        $line = ""
        foreach ($token in $tokens) {
            if ($line.Length -eq 0) {
                $line = $token
            } elseif (($line.Length + $token.Length) -le $Length) {
                $line += $token
            } else {
                $lines += $line
                $line = $token
            }
        }
        if ($line.Length -gt 0) {
            $lines += $line
        }

        $result = $lines
        $result_str = ($result -join $LineSeparator);
        return $result_str
    }
}
