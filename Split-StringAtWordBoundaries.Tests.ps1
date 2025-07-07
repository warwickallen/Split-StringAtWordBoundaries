# ========================
# Pester Test File
# ========================

Describe 'Split-StringAtWordBoundaries' {
    It 'Prints a valid version number' {
        (Split-StringAtWordBoundaries -Version)[0] |
        Should -Match '\b0\.\d+\.\d+$'
    }
    It 'Wraps string using dot delimiter and length 12' {
        Split-StringAtWordBoundaries -String 'aaa.bbb...ccc.ddd.eee.fff' -Length 12 -WordDelimiter '(\.)`.*' |
        Should -Be "aaa.bbb.`nccc.ddd.eee.`nfff"
    }

    It 'Wraps sentence with whitespace default delimiter and length 10' {
        Split-StringAtWordBoundaries -String 'This is a long sentence to wrap.' -Length 10 |
        Should -Be "This is a`nlong`nsentence`nto wrap."
    }

    It 'Wraps using dot delimiter and custom separator with length 12' {
        $sep = ([char]10 + '123')
        Split-StringAtWordBoundaries -String 'aaa.bbb...cccc.ddd.eee.fff.hhh.iii' -Length 12 -WordDelimiter '(\.)\.*' -LineSeparator $sep |
        Should -Be "aaa.bbb.`n123cccc.ddd.`n123eee.fff.`nhhh.123iii"
    }

    It 'Wraps long sentence using custom delimiter "(.) " and length 98' {
        Split-StringAtWordBoundaries -Length 98 -String 'The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed the specified length.' -WordDelimiter '(.) ' |
        Should -Be "The Split-StringAtWordBoundaries function breaks a string into multiple lines, ensuring each line does not exceed`nthe specified length."
    }

    It 'Wraps name with hyphen and length 12' {
        Split-StringAtWordBoundaries -String 'Mr Wright-Rong has a double-barrelled name.' -Length 12 |
        Should -Be "Mr Wright-`nRong has a`ndouble-`nbarrelled`nname."
    }

    It 'Wraps dot-delimited string with length 8' {
        Split-StringAtWordBoundaries -String '. a.bb cc.ddd eee.ffff gggg.hhh iii.jj kk.l . ' -Length 8 -WordDelimiter '`.' |
        Should -Be ". a`nbb cc`nddd eee`nffff gggg`nhhh iii`njj kk`nl . "
    }
}
