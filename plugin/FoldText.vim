" Modification of https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim
" Always show some delimiters (the argument of CustomFoldText) and the tail of
" the folded line, that is, the number of lines folded (absolute and relative)
function! CustomFoldText(delim)
  "get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
      let line = getline(v:foldstart)
  else
      let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  " indent foldtext corresponding to foldlevel
  let indent = repeat(' ',shiftwidth())
  let foldLevelStr = repeat(indent, v:foldlevel-1)
  let foldLineHead = substitute(line, '^\s*', foldLevelStr, '')

  " size foldtext according to window width
  let w = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
  let foldSize = 1 + v:foldend - v:foldstart

  " estimate fold length
  let foldSizeStr = " " . foldSize . " lines "
  let lineCount = line("$")
  if has("float")
    try
      let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    catch /^Vim\%((\a\+)\)\=:E806/	" E806: Using Float as String
      let foldPercentage = printf("[of %d lines] ", lineCount)
    endtry
  endif

  " build up foldtext
  let foldLineTail = foldSizeStr . foldPercentage
  let lengthTail = strlen(foldLineTail)
  let foldLineHead = strpart(foldLineHead, 0, w - (lengthTail +3))

  " truncate foldtext according to window width
  if exists("*strwdith")
    let expansionString = repeat(a:delim, w - strwidth(foldLineHead.foldLineTail))
  else
    let expansionString = repeat(a:delim, w - strlen(substitute(foldLineHead.foldLineTail, '.', 'x', 'g')))
  endif

  let foldLine = foldLineHead . expansionString . foldLineTail
  return foldLine
endfunction

" use '.' as delimiter
set foldtext=CustomFoldText('.')

