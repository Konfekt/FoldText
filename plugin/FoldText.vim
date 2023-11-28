" Modification of https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim
" Always show some delimiters (the argument of CustomFoldText) and the tail of
" the folded line, that is, the number of lines folded (absolute and relative)
function! CustomFoldText(delim)
  " Ensure delimiter is provided
  if empty(a:delim)
    let a:delim = ' '
  endif

  " Get first non-blank line within the fold
  let fs = nextnonblank(v:foldstart)
  if fs == 0 || fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  " Estimate fold length
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = " " . foldSize . " lines "
  let lineCount = line("$")

  " Calculate fold percentage if floating point support is available
  let foldPercentage = ''
  if has("float")
    try
      let foldPercentage = "[" . printf("%4s", printf("%.1f", (foldSize*1.0)/lineCount*100)) . "%] "
    catch /^Vim\%((\a\+)\)\=:E806/	" E806: Using Float as String
      let foldPercentage = printf("[of %d lines] ", lineCount)
    endtry
  endif

  " Build up foldtext
  let tail = foldSizeStr . foldPercentage

  " Calculate maximum width for the foldtext
  let maxWidth = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0) - (&signcolumn ==# 'yes' ? &numberwidth : 0)

  " Indent foldtext corresponding to foldlevel
  let indent = repeat(' ', shiftwidth())
  let foldLevelStr = repeat(indent, v:foldlevel - 1)
  let head = substitute(line, '^\s*', foldLevelStr, '')

  " Calculate available space for the head after adding the tail
  let lengthTail = strwidth(tail)
  let lengthHead = maxWidth - lengthTail

  " Truncate foldtext according to window width
  if strwidth(head) > LengthHead
    let cutLengthHead = LengthHead - strwidth('..')
    if cutLengthHead < 0
      let cutLengthHead = 0
    endif
    let head = strpart(head, 0, cutLengthHead) . '..'
  endif

  " Calculate space for the delimiter
  let lengthMiddle = maxWidth - strwidth(head) - lengthTail
  let middle = repeat(a:delim, lengthMiddle)

  return head . middle . tail
endfunction

set foldtext=CustomFoldText('\ ')

