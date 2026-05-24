$pdf_mode      = 4;          # 4 = lualatex, 5 = xelatex
$out_dir       = 'build';
$aux_dir       = 'build/aux';
$bibtex_use    = 2;
@default_files = ('main.tex');

$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error '
          . '-file-line-error -shell-escape -synctex=-1 %O %S';
$xelatex  = 'xelatex  -interaction=nonstopmode -halt-on-error '
          . '-file-line-error -shell-escape -synctex=-1 %O %S';

$failure_cmd = './bin/t diagnose';

# zathura + neovim/vimtex; change to match your viewer
$pdf_previewer = 'zathura --synctex-editor-command "nvim --remote +%l %f" %O %S';
