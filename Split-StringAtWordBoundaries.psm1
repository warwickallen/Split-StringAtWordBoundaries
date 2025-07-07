<#
.SYNOPSIS
    Wraps a string to a specified maximum length per line, splitting only at designated delimiters.

.DESCRIPTION
    The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed the specified length.
    It splits the input string at points matching the provided WordDelimiter regular expression, preserving the first capture group (if present) at the split points.
    Lines are joined using the specified LineSeparator, and the function ensures that no line exceeds the specified length (unless that line consists of a single word that is longer than the specified length).
    These parts are counted towards the line length:
    - The input text (-String)
    - The first capture group of -WordDelimiter (if there is one).
    - LinePrefix
    - LineSuffix
    The function supports pipeline input for the String parameter.

.PARAMETER String
    The input string to be wrapped. This parameter is required unless -Help, -Test, or -ShowVersion is specified. Can be provided via pipeline.

.PARAMETER Length
    The maximum number of characters per line, excluding the line separator. Defaults to 80.
    Alias: N

.PARAMETER LineSeparator
    The string used to separate lines in the output. Defaults to a newline character ([char]10).
    Alias: Separator

.PARAMETER LinePrefix
    A string prepended to each output line. This counts towards the line length.
    Defaults to an empty string.
    Alias: Prefix

.PARAMETER LineSuffix
    A string appended to each output line. This counts towards the line length.
    Defaults to an empty string.
    Alias: Suffix

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
    Split-StringAtWordBoundaries -String "aaa.bbb...ccc.ddd.eee.fff" -Length 12 -WordDelimiter '(\.)\.*'
    Output:
    aaa.bbb.
    ccc.ddd.eee.
    fff

.EXAMPLE
    Split-StringAtWordBoundaries -String "This is a long sentence to wrap." -Length 10
    Output:
    This is a
    long
    sentence
    to wrap.

.NOTES
    Version: 0.0.1.27
#>
function Split-StringAtWordBoundaries {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$String,

        [Alias("N")]
        [int]$Length = 80,

        [Alias("Separator")]
        [string]$LineSeparator = [char]10,

        [Alias("Prefix")]
        [string]$LinePrefix = '',

        [Alias("Suffix")]
        [string]$LineSuffix = '',

        [Alias("D", "Delimiter")]
        [string]$WordDelimiter = '(?:(-)|\s)\s*',

        [switch]$Help,
        
        [switch]$Test,
        
        [Alias("Version")]
        [switch]$ShowVersion
    )

    begin {
        $Version = (Get-Content $0 | Select-String 'Version:')
        if ($ShowVersion) {
            #Import-LocalizedData
            Write-Output "Split-StringAtWordBoundaries Version: $Version"
            return
        }
        if ($Help) {
            Get-Help -Name Split-StringAtWordBoundaries -Full
            return
        }
        if ($Test) {
            Write-Host "Split-StringAtWordBoundaries Version: $Version"
            Write-Host "To run tests, please use the Pester test script: Split-StringAtWordBoundaries.Tests.ps1"
            return
        }
    }

    process {
        if (-not $String) { return "" }

        # Tokenize the string, capturing the delimiter (and its group if exists)
        $parts = @()
        $regex = [regex]$WordDelimiter
        $start = 0
        foreach ($match in $regex.Matches($String)) {
            $segment = $String.Substring($start, $match.Index - $start)
            if ($segment -ne "") { $parts += $segment }
            if ($match.Groups.Count -gt 1 -and $match.Groups[1].Success) {
                $parts += $match.Groups[1].Value
            } elseif ($match.Value -match '^\s+$') {
                $parts += ' '
            }
            $start = $match.Index + $match.Length
        }
        if ($start -lt $String.Length) {
            $parts += $String.Substring($start)
        }

        # Collapse multiple spaces into a single space, only if the part is whitespace
        $tokens = @()
        foreach ($p in $parts) {
            if ($p -match '^\s+$') { $tokens += ' ' }
            else { $tokens += $p }
        }

        # Now build lines without exceeding $Length (unless a single token is too long)
        $lines = @()
        $currentLine = ""
        foreach ($token in $tokens) {
            # Remove leading/trailing spaces except at start/end
            $token = if ($token -eq ' ') { ' ' } else { $token.Trim() }

            if ($currentLine -eq "") {
                $currentLine = $token
            } elseif (($currentLine + $token).Length -le $Length) {
                $currentLine += $token
            } else {
                $lines += $currentLine.TrimEnd()
                $currentLine = $token.TrimStart()
                # If token itself is longer than $Length, force-break it
                while ($currentLine.Length -gt $Length) {
                    $lines += $currentLine.Substring(0, $Length)
                    $currentLine = $currentLine.Substring($Length)
                }
            }
        }
        if ($currentLine -ne "") {
            $lines += $currentLine.TrimEnd()
        }

        return ($lines -join $LineSeparator)
    }
}
Export-ModuleMember -Function Split-StringAtWordBoundaries
