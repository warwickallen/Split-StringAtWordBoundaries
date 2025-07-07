Split-StringAtWordBoundaries

A PowerShell function to intelligently wrap a long string.

NAME
    Split-StringAtWordBoundaries

SYNOPSIS
    Wraps a string to a specified maximum length per line, splitting only at designated delimiters.


SYNTAX
    Split-StringAtWordBoundaries [[-String] <String>] [[-Length] <Int32>] [[-LineSeparator] <String>] [[-LinePrefix] <String>] [[-LineSuffix] <String>] [[-WordDelimiter] <String>] [-Help] [-Test] [-ShowVersion] [<CommonParameters>]


DESCRIPTION
    The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed the specified length.
    It splits the input string at points matching the provided WordDelimiter regular expression, preserving the first capture group (if present) at the split points.
    Lines are joined using the specified LineSeparator, and the function ensures that no line exceeds the specified length (unless that line consists of a single word that is longer than the specified length).
    These parts are counted towards the line length:
    - The input text (-String)
    - The first capture group of -WordDelimiter (if there is one).
    - LinePrefix
    - LineSuffix
    The function supports pipeline input for the String parameter.


PARAMETERS
    -String <String>
        The input string to be wrapped. This parameter is required unless -Help, -Test, or -ShowVersion is specified. Can be provided via pipeline.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Accept wildcard characters?  false

    -Length <Int32>
        The maximum number of characters per line, excluding the line separator. Defaults to 80.
        Alias: N

        Required?                    false
        Position?                    2
        Default value                80
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LineSeparator <String>
        The string used to separate lines in the output. Defaults to a newline character ([char]10).
        Alias: Separator

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LinePrefix <String>
        A string prepended to each output line. This counts towards the line length.
        Defaults to an empty string.
        Alias: Prefix

        Required?                    false
        Position?                    4
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LineSuffix <String>
        A string appended to each output line. This counts towards the line length.
        Defaults to an empty string.
        Alias: Suffix

        Required?                    false
        Position?                    5
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -WordDelimiter <String>
        A regular expression defining where the string can be split. The matching characters are discarded, except for the first capture group (if it exists), used only at line breaks.
        Defaults to '(?:(-)|\s)\s*', i.e., a hyphen (retained) or whitespace (replaced with a single space), followed by any additional whitespace (discarded).
        Aliases: D, Delimiter

        Required?                    false
        Position?                    6
        Default value                (?:(-)|\s)\s*
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Help [<SwitchParameter>]
        Displays the help information for the function and exits.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Test [<SwitchParameter>]
        Runs predefined test cases to verify the function's behaviour and exits.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ShowVersion [<SwitchParameter>]
        Displays the current version of the function and exits.
        Alias: Version

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        Version: 0.0.1.27

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Split-StringAtWordBoundaries -String "aaa.bbb...ccc.ddd.eee.fff" -Length 12 -WordDelimiter '(\.)\.*'

    Output:
    aaa.bbb.
    ccc.ddd.eee.
    fff




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>Split-StringAtWordBoundaries -String "This is a long sentence to wrap." -Length 10

    Output:
    This is a
    long
    sentence
    to wrap.
