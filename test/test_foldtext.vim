" Headless tests for plugin/FoldText.vim.
" Run with test/run.sh, or:
"   vim -Nu NONE -i NONE -es -S test/test_foldtext.vim
"   nvim --clean --headless -S test/test_foldtext.vim
set encoding=utf-8
scriptencoding utf-8
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
execute 'source ' . fnameescape(s:root . '/plugin/FoldText.vim')

" Width of the text area: window width minus fold, number and sign columns.
function! s:TextWidth() abort
  return winwidth(0) - getwininfo(win_getid())[0].textoff
endfunction

" Fill a fresh buffer with a:n lines and fold lines 1-3 manually.
function! s:Setup(n, first) abort
  silent! %bwipeout!
  enew!
  setlocal foldmethod=manual foldcolumn=0 nonumber norelativenumber signcolumn=no
  call setline(1, [a:first] + map(range(2, a:n), '"line " . v:val'))
  1,3fold
endfunction

function! Test_FillsWindowExactly() abort
  call s:Setup(10, 'short')
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text), 'plain: ' . text)
  call assert_match('^short \+ 3 lines \[', text)
endfunction

function! Test_NumberWidthGrowsWithLineCount() abort
  call s:Setup(12345, 'short')
  setlocal number
  call assert_equal(s:TextWidth(), strwidth(foldtextresult(1)))
endfunction

function! Test_RelativeNumberOnly() abort
  call s:Setup(10, 'short')
  setlocal relativenumber
  call assert_equal(s:TextWidth(), strwidth(foldtextresult(1)))
endfunction

function! Test_SignColumnYes() abort
  call s:Setup(10, 'short')
  setlocal signcolumn=yes
  call assert_equal(s:TextWidth(), strwidth(foldtextresult(1)))
endfunction

function! Test_FoldColumn() abort
  call s:Setup(10, 'short')
  setlocal foldcolumn=4 number
  call assert_equal(s:TextWidth(), strwidth(foldtextresult(1)))
endfunction

function! Test_TruncatesMultibyteByDisplayWidth() abort
  call s:Setup(10, repeat('ä', 300))
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text))
  " Every character must survive intact: no split UTF-8 sequences.
  call assert_match('^ä\+\.\. 3 lines', text)
endfunction

function! Test_TruncatesWideCharacters() abort
  call s:Setup(10, repeat('漢', 300))
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text))
  " A wide character that does not fit is dropped and padded with a blank.
  call assert_match('^漢\+\.\.  3 lines', text)
endfunction

function! Test_MultiCharDelimiter() abort
  call s:Setup(10, 'short')
  setlocal foldtext=CustomFoldText('-=')
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text), text)
  call assert_match('^short-=-=', text)
endfunction

function! Test_SingleDelimiter() abort
  call s:Setup(10, 'short')
  setlocal foldtext=CustomFoldText('·')
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text), text)
  call assert_match('^short·\+ 3 lines', text)
endfunction

function! Test_SkipsLeadingBlankLinesAndIndentsByLevel() abort
  call s:Setup(10, '')
  call setline(2, "\tfoo\tbar")
  setlocal shiftwidth=2 tabstop=4
  3,5fold
  1,6fold
  normal! zM
  " Outer fold (level 1) starts on a blank line: show the next non-blank one.
  call assert_match('^foo    bar ', foldtextresult(1))
  1foldopen
  " Inner fold (level 2) is indented by one 'shiftwidth'.
  call assert_match('^  line 3 ', foldtextresult(3))
endfunction

function! Test_AllBlankFold() abort
  call s:Setup(10, '')
  call setline(1, ['', '', ''])
  let text = foldtextresult(1)
  call assert_equal(s:TextWidth(), strwidth(text))
  call assert_match('^ \+ 3 lines \[', text)
endfunction

function! Test_TextOffFallbackMatchesTextoff() abort
  let Fallback = function(matchstr(execute('function /TextOffFallback'),
        \ '<SNR>\d\+_TextOffFallback'))
  for n in [10, 12345]
    for opts in ['nonumber', 'number', 'relativenumber', 'number relativenumber',
          \ 'signcolumn=yes', 'foldcolumn=3 number signcolumn=yes']
      call s:Setup(n, 'short')
      execute 'setlocal' opts
      call assert_equal(getwininfo(win_getid())[0].textoff, Fallback(),
            \ n . ' lines, ' . opts)
    endfor
  endfor
endfunction

function! Test_SetsFoldtext() abort
  call assert_equal('CustomFoldText()', &g:foldtext)
endfunction

let s:failed = 0
for s:test in sort(filter(split(execute('function /^Test_'), "\n"),
      \ 'v:val =~# "^function Test_"'))
  let s:name = matchstr(s:test, 'Test_\w\+')
  let v:errors = []
  try
    call call(s:name, [])
  catch
    call add(v:errors, s:name . ': ' . v:exception . ' @ ' . v:throwpoint)
  endtry
  if empty(v:errors)
    let s:line = 'ok   ' . s:name
  else
    let s:failed += 1
    let s:line = 'FAIL ' . s:name . "\n  " . join(v:errors, "\n  ")
  endif
  if has('nvim')
    call chansend(v:stderr, s:line . "\n")
  else
    for s:l in split(s:line, "\n")
      verbose echo s:l
    endfor
  endif
endfor
if s:failed
  cquit!
endif
qall!
