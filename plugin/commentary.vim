" commentary.vim - Comment stuff out
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.3
" GetLatestVimScripts: 3695 1 :AutoInstall: commentary.vim

if exists("g:loaded_commentary") || v:version < 703
  finish
endif
let g:loaded_commentary = 1

function! s:surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:strip_white_space_go(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if l[-1:] ==# ' ' && (stridx(a:line,l) == 0 || stridx(a:line,l[:-2]) == 0)
    let l = l[:-2]
  endif
  if r[0] ==# ' ' && a:line[1-strlen(r):] == r[1:]
    let r = r[1:]
  endif
  return [l, r]
endfunction

function! s:strip_white_space_gone(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if l[-1:] ==# ' ' && stridx(a:line,l) != 0  && stridx(a:line,l[:-2]) == 0
    let l = l[:-2]
  endif
  if r[0] ==# ' ' && a:line[-strlen(r):] != r && a:line[1-strlen(r):] == r[1:]
    let r = r[1:]
  endif
  return [l, r]
endfunction

function! s:go(...) abort
  if !a:0
    let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
    return 'g@'
  elseif a:0 > 1
    let [lnum1, lnum2] = [a:1, a:2]
  else
    let [lnum1, lnum2] = [line("'["), line("']")]
  endif

  let [l, r] = s:surroundings()
  let uncomment = 2
  let force_uncomment = a:0 > 2 && a:3
  for lnum in range(lnum1,lnum2)
    let line = matchstr(getline(lnum),'\S.*\s\@<!')
    let [l, r] = s:strip_white_space_go(l,r,line)
    if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
  endfor

  if get(b:, 'commentary_startofline')
    let indent = '^'
  else
    let indent = '^\s*'
  endif

  let lines = []
  for lnum in range(lnum1,lnum2)
    let line = getline(lnum)
    if strlen(r) > 2 && l.r !~# '\\'
      let line = substitute(line,
            \'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
            \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
    endif
    if force_uncomment
      if line =~ '^\s*' . l
        let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
      endif
    elseif uncomment
      let line = substitute(line,'^\%('.matchstr(getline(lnum1),indent).'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
    else
      let line = substitute(line,'^\%('.matchstr(getline(lnum1),indent).'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
    endif
    call add(lines, line)
  endfor
  call setline(lnum1, lines)
  let modelines = &modelines
  try
    set modelines=0
    silent doautocmd User CommentaryPost
  finally
    let &modelines = modelines
  endtry
  return ''
endfunction

function! s:gone(...) abort
  if !a:0
    let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
    return 'g@'
  elseif a:0 > 1
    let [lnum1, lnum2] = [a:1, a:2]
  else
    let [lnum1, lnum2] = [line("'["), line("']")]
  endif

  let [l, r] = s:surroundings()
  let uncomment = 2
  let force_uncomment = a:0 > 2 && a:3
  for lnum in range(lnum1,lnum2)
    let line = matchstr(getline(lnum),'\S.*\s\@<!')
    let [l, r] = s:strip_white_space_gone(l,r,line)
    if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
  endfor

  if get(b:, 'commentary_startofline')
    let indent = '^'
  else
    let indent = '^\s*'
  endif

  let lines = []
  for lnum in range(lnum1,lnum2)
    let line = getline(lnum)
    if strlen(r) > 2 && l.r !~# '\\'
      let line = substitute(line,
            \'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
            \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
    endif
    if force_uncomment
      if line =~ '^\s*' . l
        let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
      endif
    elseif uncomment
      let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')

    else
      
    endif
    call add(lines, line)
  endfor
  call setline(lnum1, lines)
  let modelines = &modelines
  try
    set modelines=0
    silent doautocmd User CommentaryPost
  finally
    let &modelines = modelines
  endtry
  return ''
endfunction


" command! -range -bar -bang Commentary call s:go(<line1>,<line2>,<bang>0)
xnoremap <expr>   <Plug>Commentary     <SID>go()
xnoremap <expr>   <Plug>UnCommentary     <SID>gone()

nnoremap <expr>   <Plug>Commentary     <SID>go()
nnoremap <expr>   <Plug>UnCommentary     <SID>gone()

nnoremap <expr>   <Plug>CommentaryLine <SID>go() . '_'
nnoremap <expr>   <Plug>UnCommentaryLine <SID>gone() . '_'


if !hasmapto('<Plug>Commentary') || maparg('gc','n') ==# ''
  xmap <F8> <Plug>Commentary gv
  xmap <F9> <Plug>UnCommentary gv
  nmap <F8> <Plug>CommentaryLine
  nmap <F9> <Plug>UnCommentaryLine
endif

" vim:set et sw=2:
