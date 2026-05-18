$pdf_mode      = 4;            # 4 = lualatex, 5 = xelatex, 1 = pdflatex
$out_dir       = 'build';
$aux_dir       = 'build/aux';
$bibtex_use    = 2;            # always run biber when .bcf exists
@default_files = ('main.tex');

# Stop immediately on the first error and emit file:line:error format
# so editors can jump straight to the failure.
$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error '
          . '-file-line-error -synctex=1 %O %S';
$xelatex  = 'xelatex  -interaction=nonstopmode -halt-on-error '
          . '-file-line-error -synctex=1 %O %S';

# On failure, parse the log and print a runnable fix command.
$failure_cmd = './bin/t diagnose';

# Use zathura for forward/inverse search with neovim/vimtex
$pdf_previewer = 'zathura --synctex-editor-command "nvim --remote +%l %f" %O %S';
