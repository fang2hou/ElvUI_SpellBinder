# ElvUI SpellBinder

## [1.1.0-2](https://github.com/lenonk/ElvUI_SpellBinder/tree/1.1.0-2) (2018-11-25)
[Full Changelog](https://github.com/lenonk/ElvUI_SpellBinder/compare/1.1.0-1...1.1.0-2)

- Removed the line from prototypes.lua in the AceGUI SharedMediaWidgets  
    library that's been causing problems for some users.  Some part of the  
    BigWigs package script causes duplciation of comment blocks on the  
    offending line, which causes SpellBinder to produce a lua error.  
    Removing the line is not the best fix, but it's better than trying to  
    fix the packaging script.  
