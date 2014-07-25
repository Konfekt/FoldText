FoldText

==

This is a modification of the `CustomFoldText` function that is more amenable to
`syntax` folds.

It can be found at

https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim

and is in turn a modification of the `CustomFoldText` function of Greg Sexton at

http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold

==

Example settings

```
set foldmethod=syntax

" { Syntax Folding
  let g:vimsyn_folding='af'
  let g:tex_fold_enabled=1
  let g:xml_syntax_folding = 1
  let g:clojure_fold = 1
  let ruby_fold = 1
  let perl_fold = 1
  let perl_fold_blocks = 1
" }

set foldenable
set foldcolumn=4
set foldnestmax=3
set foldlevel=0
set foldlevelstart=0
" specifies for which commands a fold will be opened
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
" set foldopen=all
" set foldclose=all

" Change Option Folds
nnoremap zi :call <SID>ToggleFoldcolumn()<CR>

nnoremap <expr> zl &wrap ? 'zx' : 'zl'

nnoremap <silent> zr zr:setlocal foldlevel?<cr>
nnoremap <silent> zm zm:setlocal foldlevel?<cr>

nnoremap <silent> zR zR:setlocal foldlevel?<cr>
nnoremap <silent> zM zM:setlocal foldlevel?<cr>

function! s:ToggleFoldcolumn()
  if &foldcolumn
    let w:foldcolumn = &foldcolumn
    silent setlocal foldcolumn=0
    silent setlocal nofoldenable
  else
      if exists('w:foldcolumn') && (w:foldcolumn!=0)
        silent let &l:foldcolumn=w:foldcolumn
      else
        silent setlocal foldcolumn=4
      endif
      silent setlocal foldenable
  endif
  setlocal foldcolumn?
endfunction

```
