"==============================================================================
"Script Title: rainbow parentheses improved
"Script Version: 2.41
"Author: luochen1990
"Last Edited: 2012 Oct 28
"Simple Configuration:
"	first, put "rainbow.vim"(this file) to dir vim73/plugin or vimfiles/plugin
"	second, add the follow sentence to your .vimrc or _vimrc :
"
"	 		let g:rainbow_active = 1
"
"	third, restart your vim and enjoy coding.
"Advanced Configuration:
"	an advanced configuration allows you to define what parentheses to use 
"	for each type of file . you can also determine the colors of your 
"	parentheses by this way.
"		e.g. this is an advanced config (add these sentences to your vimrc):
"
"	 		let g:rainbow_active = 1
"  	 
"  	 		let g:rainbow_filetype_matchpairs = {
"			\	 '*'     : [['(', ')'], ['\[', '\]'], ['{', '}']],
"			\	 'tex'   : [['(', ')'], ['\[', '\]']],
"			\	 'c,cpp' : [['(', ')'], ['\[', '\]'], ['{', '}']],
"			\	 'html'  : [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']],
"			\	}
"  	 
"  	 		let g:rainbow_guifgs = ['RoyalBlue3', 'SeaGreen3', 'DarkOrange3', 'FireBrick',]
"
"User Command:
"	:RainbowToggle		--you can use it to toggle this plugin.


let s:guifgs = exists('g:rainbow_guifgs')? g:rainbow_guifgs : [
			\ 'DarkOrchid3', 'RoyalBlue3', 'SeaGreen3',
			\ 'DarkOrange3', 'FireBrick', 
			\ ]

let s:ctermfgs = exists('g:rainbow_ctermfgs')? g:rainbow_ctermfgs : [
			\ 'darkgray', 'Darkblue', 'darkmagenta', 
			\ 'darkcyan', 'darkred', 'darkgreen',
			\ ]

let s:max = has('gui_running')? len(s:guifgs) : len(s:ctermfgs)

" A dictionary of filetypes and their respective parenthese regionpatterns
let s:ftpairs = exists('g:rainbow_filetype_matchpairs')? g:rainbow_filetype_matchpairs : {
			\	 '*'     : [['(', ')'], ['\[', '\]'], ['{', '}']]
            \ }


" The name of the syntax region group, used in the syntax command, defining the parenthese region pattern
let s:sgroup = 'RainbowSyntax'

" The name of the highlight group, used in the highlight command, defining the color selection
let s:hgroup = 'RainbowHighlight'

" Creates the Syntax Regions based on the list of match pairs
func rainbow#loadsyntaxgroups(matchpairs)
    let cmd = 'syn region %s matchgroup=%s start=+%s+ end=+%s+ containedin=%s contains=TOP,' . join(map(range(1, s:max), 's:sgroup . v:val'), ',')
    for [left , right] in a:matchpairs
        for id in range(1, s:max)
            exe printf(cmd, s:sgroup.id, s:hgroup.id, left, right, id < s:max ? s:sgroup.(id+1) : s:sgroup."1")
        endfor
    endfor
endfunc

" Clears any syntax region created by this plugin
func rainbow#clearsyntaxgroups()
	for id in range(1, s:max)
		exe 'syn clear '.s:sgroup.id
	endfor
endfunc

" Inserts a matchpair into the buffer's current collection of matchpairs and
" reload the syntax regions
func rainbow#insertmatchpairs(...)
    if !exists('b:rainbow_matchpairs')
        let b:rainbow_matchpairs = []
    else
        call rainbow#clearsyntaxgroups()
    endif

    call insert(b:rainbow_matchpairs, a:000)
    call rainbow#loadsyntaxgroups(b:rainbow_matchpairs)
endfunc

" Removes a matchpair from the buffer's current collection of matchpairs and
" reloads the syntax region
func rainbow#removematchpairs(...)
    if exists('b:rainbow_matchpairs')
        call rainbow#clearsyntaxgroups()
        call filter(b:rainbow_matchpairs, 'v:val != a:000')
        if empty(b:rainbow_matchpairs)
            unlet b:rainbow_matchpairs
        else
            call rainbow#loadsyntaxgroups(b:rainbow_matchpairs)
        endif
    endif
endfunc

" Attempts to populate the buffer's matchpairs list based on the filetype and
" reloads the syntax regions
func rainbow#activatebuffer()
    if !exists("b:rainbow_matchpairs")
        call rainbow#loadmatchpairsforfiletype(&ft)
    endif
endfunc

" Load the syntax region from the matchpairs associated with a filetype
func rainbow#loadmatchpairsforfiletype(ft)
    let key = get(filter(keys(s:ftpairs), 'v:val =~ ''\<'.a:ft.'\>'''), 0, '*')
    call rainbow#loadmatchpairs( has_key(s:ftpairs, l:key) ? s:ftpairs[l:key] : [])
endfunc

" Load the syntax region from the matchpairs 
func rainbow#loadmatchpairs(matchpairs)
    if exists('b:rainbow_matchpairs')
        call rainbow#clearsyntaxgroups()
    endif

    if empty(a:matchpairs)
        unlet! b:rainbow_matchpairs
    else
        let b:rainbow_matchpairs = a:matchpairs
        call rainbow#loadsyntaxgroups(b:rainbow_matchpairs)    
    endif
endfunc

" Creates the highlight groups referenced by the syntax regions
func rainbow#activate()
	for id in range(1 , s:max)
		let ctermfg = s:ctermfgs[(s:max - id) % len(s:ctermfgs)]
		let guifg   = s:guifgs[(s:max - id) % len(s:guifgs)]
		exe 'hi default '.s:hgroup.id.' ctermfg='.ctermfg.' guifg='.guifg
	endfor
	let g:rainbow_active = 'active'

    if !empty(s:ftpairs)
        augroup RainbowParenthesis
            au!
            if has_key(s:ftpairs, '*')
                auto filetype * call rainbow#loadmatchpairsforfiletype(&ft)
            else
                for ft in keys(s:ftpairs)
                    exe 'auto filetype '. ft . ' call rainbow#loadmatchpairs('. string(s:ftpairs[ft]) .')'
                endfor
            endif
        augroup END        
    endif
endfunc

" Destroyes the highlight groups referenced by the syntax regions
func rainbow#inactivate()
	if exists('g:rainbow_active')
		for id in range(1, s:max)
			exe 'hi clear '.s:hgroup.id
		endfor
		unlet g:rainbow_active
	endif

    augroup! RainbowParenthesis
endfunc

" Activates/Deactivates the Rainbow Parenthesis
func rainbow#toggle()
	if exists('g:rainbow_active')
		call rainbow#inactivate()
	else
        " BufDo call rainbow#activatebuffer()
        " If no matchpair definition exists, try loading from the filetype
        let origin = bufnr("%")
        for b in filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(getbufvar(v:val, "rainbow_matchpairs"))')
            exe "buffer ". b
            call rainbow#activatebuffer()
        endfor
        exe "buffer ". l:origin
		call rainbow#activate()
	endif    
endfunc

" Plugin Commands
command!          RainbowToggle call rainbow#toggle()
command! -nargs=+ RainbowInsert call rainbow#insertmatchpairs(<f-args>)
command! -nargs=+ RainbowRemove call rainbow#removematchpairs(<f-args>)

