# Paper Title

> One-line abstract. Replace with the actual paper.

This repository contains the LaTeX source for the paper, a reproducible build setup, and a minimal toolchain that does not depend on a full TeX Live install.

## Quick start

```bash
# 1. Install the TeX engine (one-time, ~150 MB)
curl -sL https://yihui.org/tinytex/install-bin-unix.sh | sh
export PATH="$HOME/.TinyTeX/bin/$(uname -m)-linux:$PATH"

# 2. Install project dependencies (reads tex-packages.toml)
./scripts/tex-add restore

# 3. Build
latexmk
```

The output PDF lands at `build/main.pdf`. Source files stay clean: every `.aux`, `.log`, `.bbl`, and `.fls` lives under `build/`.

If the build fails because a package is missing, `latexmk` will print the exact `tex-add add ...` command to fix it. See [Recovering from a failed build](#recovering-from-a-failed-build).

## Prerequisites

- **[TinyTeX](https://yihui.org/tinytex/)** — minimal TeX Live (~150 MB). Bundles `tlmgr`, `latexmk`, `biber`, and every standard engine.
- **A modern engine.** This project compiles with **LuaLaTeX**. XeLaTeX works as a fallback; pdfLaTeX is not supported (we rely on OpenType math fonts).
- **Python 3.11+** for the `tex-add` helper (standard library only).
- **Optional:** `biber` for the bibliography backend (TinyTeX bundles it; on Linux you may need `ln -s ~/.TinyTeX/bin/*/biber ~/bin/`).

A full TeX Live install also works; nothing here is TinyTeX-specific other than the install command above.

## Project structure

```
.
├── README.md
├── main.tex                 # entry point
├── tex-packages.toml        # declared package dependencies (manifest)
├── .latexmkrc               # build config
├── src/
│   ├── _preamble.tex        # \usepackage{...}, macros, math font setup
│   ├── 01-introduction.tex
│   ├── 02-method.tex
│   ├── 03-results.tex
│   └── 04-discussion.tex
├── figures/
│   └── *.pdf
├── refs.bib
├── scripts/
│   └── tex-add              # package manager wrapper
└── build/                   # generated; gitignored
```

## Build

| Command | Effect |
|---|---|
| `latexmk` | Single build into `build/`. Halts on first error and prints a fix suggestion. |
| `latexmk -pvc` | Watch mode; auto-rebuilds and refreshes the viewer. |
| `latexmk -c` | Clean intermediates (keeps PDF). |
| `latexmk -C` | Clean everything including PDF. |

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
$failure_cmd = './scripts/tex-add diagnose';

# Use zathura for forward/inverse search with neovim/vimtex
$pdf_previewer = 'zathura --synctex-editor-command "nvim --remote +%l %f" %O %S';
```

## Recovering from a failed build

When the build fails on a missing package, latexmk's `$failure_cmd` runs `tex-add diagnose` automatically. Typical output:

```
! LaTeX Error: File `tikz-cd.sty' not found.
warn  build references 1 missing file(s):
  - tikz-cd.sty

suggested: tex-add add tikz-cd
```

Run the suggested command, then re-run `latexmk`. If you'd rather skip the copy-paste, `./scripts/tex-add missing` does the diagnose-then-install in one step (with a confirmation prompt).

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

We use **OpenType math fonts** via `unicode-math`. The relevant preamble lines:

```latex
\usepackage{fontspec}
\usepackage{unicode-math}

\setmainfont{Libertinus Serif}
\setsansfont{Libertinus Sans}
\setmonofont{JetBrains Mono}[Scale=MatchLowercase]
\setmathfont{Libertinus Math}

% Range fallback for symbols the primary font misses
\setmathfont{STIX Two Math}[range={\setminus,\smallsetminus}]
```

Why: one font handles all math, you can paste real Unicode math characters (α, ∇, ⊗, ℝ) directly into source, and `microtype` works fully under LuaLaTeX. See `src/_preamble.tex` for the full setup.

### Font alternatives (all free)

- **Latin Modern Math** — classic Computer Modern look, default if you want zero opinions.
- **New Computer Modern Math** — modernized CM, sharper at screen sizes.
- **Libertinus Math** — the default for this project.
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
| `algorithm2e` | algorithm pseudocode |

## Dependency management

Inspired by Cargo. The `tex-packages.toml` declares packages; it's committed alongside the source.

```toml
# tex-packages.toml
[packages]
mathtools    = "*"
physics2     = "*"
siunitx      = ">=3.0"
cleveref     = "*"
biblatex     = "*"
unicode-math = "*"
```

The helper script `scripts/tex-add` wraps `tlmgr` for an ergonomic CLI:

| Command | Purpose |
|---|---|
| `tex-add search siunitx tikz-cd` | Search tlmgr by package name and filename; takes one or more terms. |
| `tex-add search amsmath.sty` | If a term ends in `.sty`/`.cls`/`.tex`/etc., it's treated as a filename. |
| `tex-add add tikz-cd pgfplots` | Install packages and append them to `tex-packages.toml`. |
| `tex-add diagnose` | Parse `build/main.log`, list missing files, print a suggested install command. Exits 1 if anything is missing. |
| `tex-add diagnose path/to/file.log` | Same, on a specific log. |
| `tex-add missing` | Diagnose, then prompt before installing the suggested packages. |
| `tex-add restore` | Install everything declared in `tex-packages.toml`. |

`diagnose` is wired into `.latexmkrc` as `$failure_cmd`, so a missing-package build failure self-documents the fix without you having to remember any of these commands.

## Reproducibility

Bit-identical PDFs across machines require all three of:

1. **Same TeX engine version.** Pin TinyTeX with a specific TeX Live year (`TINYTEX_INSTALLER=installer-2025 ...`).
2. **Same package versions.** Lock with `tlmgr info --only-installed --data name,cat-version > tex-packages.lock` and commit it. `tex-add restore` can be extended to read this for strict pinning.
3. **Stripped PDF metadata.** Add to the preamble:

   ```latex
   \pdfvariable suppressoptionalinfo 512   % LuaLaTeX
   ```

   (Under pdfLaTeX use `\pdfinfoomitdate=1` and `\pdfsuppressptexinfo=-1`.)

If true byte-level reproducibility matters more than engine flexibility, switch to [Tectonic](https://tectonic-typesetting.github.io/) and pin a bundle URL in `Tectonic.toml`. The tradeoff: Tectonic is XeTeX-only in practice (LuaLaTeX support is in progress but not stable), lags TeX Live releases, and a few packages (notably `microtype` protrusion) don't fully work.

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
