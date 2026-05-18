# Paper Title

> One-line abstract. Replace with the actual paper.

This repository contains the LaTeX source for the paper, a reproducible build setup, and a minimal toolchain that does not depend on a full TeX Live install.

## Quick start

```bash
# 1. Install TinyTeX (one-time, ~150 MB). The installer adds itself to
#    PATH automatically; restart your shell after it finishes.
curl -sL https://yihui.org/tinytex/install-bin-unix.sh | sh

# 2. Restore project dependencies and build.
./bin/t restore
make            # or: latexmk
```

The output PDF lands at `build/main.pdf`. Source files stay clean: every `.aux`, `.log`, `.bbl`, and `.fls` lives under `build/`.

If the build fails because a package is missing, `latexmk` will print the exact `t add ...` command to fix it. See [Recovering from a failed build](#recovering-from-a-failed-build).

## Prerequisites

- **[TinyTeX](https://yihui.org/tinytex/)** — minimal TeX Live (~150 MB). Bundles `tlmgr`, `latexmk`, `biber`, and every standard engine.
- **A modern engine.** This project compiles with **LuaLaTeX**. XeLaTeX works as a fallback; pdfLaTeX is not supported (we rely on OpenType math fonts).
- **Python 3** for the `bin/t` helper (3.11+ uses the stdlib `tomllib`; older Pythons can `pip install tomli`).

A full TeX Live install also works; nothing here is TinyTeX-specific other than the install command above.

## Project structure

```
.
├── README.md
├── Makefile                 # `make`, `make watch`, `make clean`
├── main.tex                 # entry point
├── tex-packages.toml        # declared package dependencies (manifest)
├── .latexmkrc               # build config
├── src/
│   ├── _preamble.tex        # \usepackage{...}, macros, math font setup
│   ├── 01-introduction.tex
│   ├── 02-method.tex
│   ├── 03-results.tex
│   └── 04-discussion.tex
├── figures/                 # put external .pdf / .png assets here
├── refs.bib
├── bin/
│   └── t                    # package manager wrapper (mnemonic: tex)
└── build/                   # generated; gitignored
```

## Build

| Command | Effect |
|---|---|
| `make` / `latexmk` | Single build into `build/`. Halts on first error and prints a fix suggestion. |
| `make watch` / `latexmk -pvc` | Watch mode; auto-rebuilds and refreshes the viewer. |
| `make clean` / `latexmk -c` | Clean intermediates (keeps PDF). |
| `make realclean` / `latexmk -C` | Clean everything including PDF. |

### `.latexmkrc`

```perl
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
```

## Recovering from a failed build

When the build fails on a missing package, latexmk's `$failure_cmd` runs `t diagnose` automatically. Typical output:

```
! LaTeX Error: File `tikz-cd.sty' not found.
warn  build references 1 missing file(s):
  - tikz-cd.sty

suggested: t add tikz-cd
```

Run the suggested command, then re-run `latexmk`. If you'd rather skip the copy-paste, `./bin/t missing` does the diagnose-then-install in one step (with a confirmation prompt).

## Editor setup

### neovim + VimTeX (recommended)

Tested setup:

- [`lervag/vimtex`](https://github.com/lervag/vimtex) — compiler, motions, concealment, SyncTeX.
- [`L3MON4D3/LuaSnip`](https://github.com/L3MON4D3/LuaSnip) — snippets; pair with `iurimateus/luasnip-latex-snippets.nvim` for math-heavy work.
- [`latex-lsp/texlab`](https://github.com/latex-lsp/texlab) — diagnostics, completion, citation lookup.

Minimal VimTeX config:

```lua
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_view_method     = 'zathura'
vim.g.vimtex_quickfix_mode   = 0
```

VimTeX reads `.latexmkrc` automatically, so the build config above is the single source of truth. The `-file-line-error` flag means VimTeX's quickfix list jumps straight to the offending source line.

### Alternatives

- **VS Code:** LaTeX Workshop extension; point it at `latexmk`.
- **Web:** Overleaf works if you mirror `_preamble.tex` and upload `refs.bib`. Note that Overleaf's TeX Live release may differ from yours; reproducibility guarantees don't carry over.

## Modern unicode-math workflow

We use OpenType math fonts via `unicode-math`. The default stack is Latin Modern because it ships with every TinyTeX install, so the skeleton compiles immediately:

```latex
\usepackage{fontspec}
\usepackage{unicode-math}

\setmainfont{Latin Modern Roman}
\setsansfont{Latin Modern Sans}
\setmonofont{Latin Modern Mono}[Scale=MatchLowercase]
\setmathfont{Latin Modern Math}
```

Why OTF math: one font handles all math, you can paste real Unicode math characters ($\alpha$, $\nabla$, $\otimes$, $\mathbb{R}$) directly into source, and `microtype` works fully under LuaLaTeX. See `src/_preamble.tex` for the full setup.

### Switching fonts

To change the math stack, install the fonts and edit the four `\set...font` lines in `src/_preamble.tex`. Free alternatives we like:

- **Libertinus Math** + **STIX Two Math** fallback — `./bin/t add libertinus-fonts stix2-otf`.
- **New Computer Modern Math** — modernized CM, sharper at screen sizes.
- **STIX Two Math** — broadest symbol coverage; preferred by IEEE/Nature-style journals.
- **TeX Gyre {Termes,Pagella,Bonum,Schola} Math** — Times/Palatino/Bookman/Century with matching math.
- **Erewhon Math** — Utopia-flavored, very readable.
- **Fira Math** — sans-serif math, good for slides.

## Package stack

Declared in `tex-packages.toml`. The core set:

| Package | Purpose |
|---|---|
| `fontspec` | OTF text fonts |
| `unicode-math` | OTF math fonts |
| `mathtools` | amsmath superset |
| `physics2` | clean bracket/derivative macros |
| `siunitx` | units, numbers, tabular numerical data |
| `cleveref` | smart cross-references (`\cref{eq:loss}` → "equation 3") |
| `biblatex` + `biber` | modern bibliography |
| `csquotes` | quotes that interact correctly with biblatex |
| `microtype` | protrusion and font expansion |
| `booktabs` | tables that don't look like 1995 |
| `tikz` + `pgfplots` | figures |

## Dependency management

Inspired by Cargo. The `tex-packages.toml` declares packages; it's committed alongside the source.

```toml
# tex-packages.toml
[packages]
mathtools    = "*"
physics2     = "*"
siunitx      = "*"
cleveref     = "*"
biblatex     = "*"
unicode-math = "*"
```

Every entry uses `"*"` — version pinning isn't enforced yet (see [Reproducibility](#reproducibility)).

The helper script `bin/t` (mnemonic: tex) wraps `tlmgr` for an ergonomic CLI:

| Command | Purpose |
|---|---|
| `t search siunitx tikz-cd` | Search tlmgr by package name and filename; takes one or more terms. |
| `t search amsmath.sty` | If a term ends in `.sty`/`.cls`/`.tex`/etc., it's treated as a filename. |
| `t add tikz-cd pgfplots` | Install packages and append them to `tex-packages.toml`. |
| `t diagnose` | Parse `build/aux/main.log`, list missing files, print a suggested install command. Exits 1 if anything is missing. |
| `t diagnose path/to/file.log` | Same, on a specific log. |
| `t missing` | Diagnose, then prompt before installing the suggested packages. |
| `t restore` | Install everything declared in `tex-packages.toml`. |

`diagnose` is wired into `.latexmkrc` as `$failure_cmd`, so a missing-package build failure self-documents the fix without you having to remember any of these commands.

## Reproducibility

The preamble runs `\pdfvariable suppressoptionalinfo 512` under LuaLaTeX, so timestamps and engine fingerprints don't leak into the PDF. The manifest tracks package names, not versions; if you need byte-identical PDFs across machines, switch to [Tectonic](https://tectonic-typesetting.github.io/) and pin a bundle URL in `Tectonic.toml`. Tradeoffs: Tectonic is XeTeX-only in practice, lags TeX Live releases, and a few packages (notably `microtype` protrusion) don't fully work.

## License

Paper text and figures: CC BY 4.0. Code (scripts, build config): MIT.

## Citation

```bibtex
@article{lastname2026title,
  title   = {Paper Title},
  author  = {Last, First},
  journal = {Journal},
  year    = {2026}
}
```
