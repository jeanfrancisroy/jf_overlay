" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
set sw=2
" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
set iskeyword+=:

" pour les accents dans vim-latex 
imap <buffer> <leader>it <Plug>Tex_InsertItemOnThisLine
imap <C-b> <Plug>Tex_MathBF
imap <C-c> <Plug>Tex_MathCal
imap <C-l> <Plug>Tex_LeftRight

" let g:Tex_CompileRule_dvi = 'latex -interaction=nonstopmode -src-specials $*'
" let g:Tex_ViewRule_dvi = 'xdvi -editor "gvim --servername GVIM --remote +\%l \%f" &> /dev/null'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_ViewRule_pdf = "evince >> /dev/null 2>&1"

let g:Tex_IgnoredWarnings =
    \'Underfull'."\n".
    \'Overfull'."\n".
    \'Font Warning'."\n".
    \'specifier changed to'."\n".
    \'You have requested'."\n".
    \'Missing number, treated as zero.'."\n".
    \'There were undefined references'."\n".
    \'Citation %.%# undefined'
let g:Tex_IgnoreLevel = 8
let g:Tex_FoldedEnvironments = 'verbatim,comment,eq,gather,align,figure,table,thebibliography,keywords,abstract,titlepage,theorem,lemma,corollary,proof,proposition,frame'

call IMAP('EFE', "\\begin{frame}{<++>}\<CR><++>\<CR>\\end{frame}<++>", 'tex')
call IMAP('ETH', "\\begin{theorem}[<++>]\<CR><++>\<CR>\\\label{thm:<++>}\<CR>\\end{theorem}<++>",'tex')
call IMAP('ECO', "\\begin{corollary}[<++>]\<CR><++>\<CR>\\\label{c:<++>}\<CR>\\end{corollary}<++>",'tex')
call IMAP('ELE', "\\begin{lemma}[<++>]\<CR><++>\<CR>\\\label{lm:<++>}\<CR>\\end{lemma}<++>",'tex')
call IMAP('EPR', "\\begin{proof}\<CR><++>\<CR>\\end{proof}", 'tex')
call IMAP('EFI', "\\begin{figure}{<+htpb+>}\<CR>\\begin{center}\<CR>\includegraphics[<++>]{<++>}\<CR>\\end{center}\<CR>\\caption[<++>]{<++>}\<CR>\\label{fig:<++>}\<CR>\\end{figure}<++>", 'tex')
