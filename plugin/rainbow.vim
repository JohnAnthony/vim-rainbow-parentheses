" rainbow       Highlight matching parentheses with multiple colors.
" Author:       dbarsam
" HomePage:     https://github.com/dbarsam/vim-rainbow-parentheses
" Readme:       https://github.com/dbarsam/vim-rainbow-parentheses/blob/master/README
" Version:      1.0
" Licence:      This program is free software; you can redistribute it and/or modify
"               it under the terms of the GNU General Public License. See 
"               http://www.gnu.org/copyleft/gpl.txt 

" Plugin Commands
command!          RainbowToggle call rainbow#toggle()
command! -nargs=+ RainbowInsert call rainbow#insertmatchpairs(<f-args>)
command! -nargs=+ RainbowRemove call rainbow#removematchpairs(<f-args>)

" Initiate the Plugin State
if exists("g:rainbow_active") && g:rainbow_active
	call rainbow#toggle()
endif
