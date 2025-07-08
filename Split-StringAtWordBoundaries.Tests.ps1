# ========================
# Pester Test File
# ========================

Describe 'Split-StringAtWordBoundaries' {
    It 'Prints a valid version number' {
        (Split-StringAtWordBoundaries -Version)[0] |
        Should -Match '\b0\.\d+\.\d+$'
    }

    It 'Wraps sentence with whitespace default delimiter and length 10' {
        'This is a long sentence to wrap.' |
        Split-StringAtWordBoundaries -Length 10 |
        Should -Be "This is a`nlong`nsentence`nto wrap."
    }

    It 'Wraps string using dot delimiter and length 12' {
        'aaa.bbb...ccc.ddd.eee.fff' |
        Split-StringAtWordBoundaries -Length 12 -WordDelimiter '(\.)`.*' -LineSuffix '\1' |
        Should -Be "aaa.bbb.`nccc.ddd.eee.`nfff"
    }

    It 'Wraps using dot delimiter and custom separator with length 12' {
        $sep = ([char]10 + '123')
        'aaa.bbb...cccc.ddd.eee.fff.hhh.iii' |
        Split-StringAtWordBoundaries -Length 12 -WordDelimiter '(\.)\.*' -LineSuffix '\1' -LineSeparator $sep |
        Should -Be "aaa.bbb.`n123cccc.ddd.`n123eee.fff.`nhhh.123iii"
    }

    It 'Wraps long sentence using custom delimiter "(.) " and length 98' {
        'The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed the specified length.' |
        Split-StringAtWordBoundaries -Length 98 -WordDelimiter '(.) ' -LineSuffix '\1' |
        Should -Be "The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line`ndoes not exceed the specified length."
    }

    It 'Wraps long sentence using custom delimiter "(.)" and length 96' {
        'The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed the specified length.' |
        Split-StringAtWordBoundaries -Length 96 -WordDelimiter '(.)' -LineSuffix '\1' |
        Should -Be "The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each lin`ne does not exceed the specified length."
    }

    It 'Wraps name with hyphen and length 12' {
        'Mr Wright-Rong has a double-barrelled name.' |
        Split-StringAtWordBoundaries -Length 12 |
        Should -Be "Mr Wright-`nRong has a`ndouble-`nbarrelled`nname."
    }

    It 'Wraps dot-delimited string with length 8' {
        '. a.bb cc.ddd eee.ffff gggg.hhh iii.jj kk.l . ' |
        Split-StringAtWordBoundaries -Length 8 -WordDelimiter '`.' |
        Should -Be ". a`nbb cc`nddd eee`nffff gggg`nhhh iii`njj kk`nl . "
    }

    It 'Wraps string using a line prefix and a line suffix' {
        'The quick brown fox jumps over the lazy dog.' |
        Split-StringAtWordBoundaries -Length 16 -LinePrefix '  ~' -LineSuffix '~' |
        Should -Be "  ~The quick~`n  ~brown fox~`n  ~jumps over~`n  ~the lazy dog.~"
    }

    It 'Wraps string using two capture groups with a look-ahead' {
        'The stupendously speedy, astonishingly agile and tremendously tireless brown fox continuously jumps over the remarkably lazy, and rather fat, dog.' |
        Split-StringAtWordBoundaries -Length 16 -WordDelimiter '(\S). .(\S)' -LinePrefix '<(\2)~' -LineSuffix '~(\1)>' |
        Should -Be "<~T~h>`n<t~upendous~l>`n<p~eed~y>`n<s~tonishing~l>`n<g~ile a~n>`n<r~emendous~l>`n<i~reless bro~w>`n<o~~>`n<o~ntinuous~l>`n<u~mps over t~h>`n<e~markably laz~y>`n<n~d rather fa~t>`n<o~g.~>"
    }
}
