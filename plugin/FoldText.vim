" Modification of https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim
" Always show some delimiters (the argument of CustomFoldText) and the tail of
" the folded line, that is, the number of lines folded (absolute and relative)

if exists('g:loaded_foldtext')
  finish
endif
let g:loaded_foldtext = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

" Number of screen cells taken by the fold, number and sign columns.
function! s:TextOff() abort
  let info = get(getwininfo(win_getid()), 0, {})
  return has_key(info, 'textoff') ? info.textoff : s:TextOffFallback()
endfunction

" Estimate for Vim and Neovim versions whose getwininfo() lacks 'textoff'.
function! s:TextOffFallback() abort
  let off = str2nr(&foldcolumn)
  if &number || &relativenumber
    let maxNumber = &number ? line('$') : winheight(0)
    let off += max([&numberwidth, len(string(maxNumber)) + 1])
  endif
  if &signcolumn =~# '^yes'
    let off += 2
  endif
  return off
endfunction

" Cut a:str to at most a:width screen cells without splitting characters.
function! s:Truncate(str, width) abort
  if a:width <= 0
    return ''
  endif
  let str = strcharpart(a:str, 0, a:width)
  while strwidth(str) > a:width
    let str = strcharpart(str, 0, strchars(str) - 1)
  endwhile
  return str
endfunction

" Replace each tab by the blanks up to the next tab stop, as displayed.
function! s:ExpandTabs(str) abort
  let parts = split(a:str, '\t', 1)
  let str = parts[0]
  for part in parts[1:]
    let str .= repeat(' ', strdisplaywidth("\t", strdisplaywidth(str))) . part
  endfor
  return str
endfunction

function! CustomFoldText(...) abort
  " default to blank as delimiter
  let delim = a:0 > 0 && !empty(a:1) ? a:1 : ' '

  " Get first non-blank line within the fold
  let fs = nextnonblank(v:foldstart)
  let line = fs == 0 || fs > v:foldend ? '' : getline(fs)

  " Tail: number of folded lines, absolute and relative to the buffer
  let foldSize = 1 + v:foldend - v:foldstart
  let tail = ' ' . foldSize . ' lines '
  if has('float')
    let tail .= '[' . printf('%4s', printf('%.1f', foldSize * 100.0 / line('$'))) . '%] '
  endif

  " Indent foldtext corresponding to foldlevel
  let foldLevelStr = repeat(' ', shiftwidth() * (v:foldlevel - 1))
  let head = s:ExpandTabs(foldLevelStr . substitute(line, '^\s*', '', ''))

  " Truncate the head so that head and tail fit into the window
  let maxWidth = winwidth(0) - s:TextOff()
  let lengthHead = maxWidth - strwidth(tail)
  if strwidth(head) > lengthHead
    let head = s:Truncate(head, lengthHead - strwidth('..')) . '..'
  endif

  " Fill the gap between head and tail with the delimiter
  let lengthMiddle = maxWidth - strwidth(head) - strwidth(tail)
  let middle = lengthMiddle > 0 ? repeat(delim, lengthMiddle) : ''
  let middle = s:Truncate(middle, lengthMiddle)
  let middle .= repeat(' ', lengthMiddle - strwidth(middle))

  return head . middle . tail
endfunction

" Keep a CustomFoldText() with a delimiter already set, e.g. in the vimrc.
if &g:foldtext !~# '^CustomFoldText('
  set foldtext=CustomFoldText()
endif

let &cpoptions = s:cpo_save
unlet s:cpo_save
