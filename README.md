# Paper Title

> One-line abstract. Replace with the actual paper.

## Quick start

```bash
# 1. Install TinyTeX (~150 MB, one-time). Restart your shell after.
curl -sL https://yihui.org/tinytex/install-bin-unix.sh | sh

# 2. Restore project packages and build.
./bin/t restore
make
```

Output lands at `build/main.pdf`. All intermediates go to `build/`.

If the build fails on a missing package, `latexmk` runs `t diagnose` automatically and prints the fix command. Run it, then `make` again.

## Prerequisites

- [TinyTeX](https://yihui.org/tinytex/) or any full TeX Live install
- LuaLaTeX (XeLaTeX works; pdfLaTeX does not, we use OpenType math fonts)
- Python 3 for `bin/t` (3.11+ has `tomllib` built in; older versions need `pip install tomli`)

## Project structure

```
.
├── Makefile
├── main.tex                 # entry point
├── tex-packages.toml        # package manifest
├── .latexmkrc               # build config (engine, output dirs, failure hook)
├── src/
│   ├── _preamble.tex        # packages, macros, font setup
│   ├── 01-introduction.tex
│   ├── 02-method.tex
│   ├── 03-results.tex
│   └── 04-discussion.tex
├── figures/
├── refs.bib
└── bin/t                    # package manager helper; run `./bin/t --help`
```

## Build

| Command | Effect |
|---|---|
| `make` | Build `build/main.pdf`. Halts on first error. |
| `make watch` | Continuous rebuild + viewer refresh. |
| `make clean` | Remove intermediates, keep PDF. |
| `make realclean` | Remove everything including PDF. |
| `make lint` | Run `chktex`. |
| `make fmt` | Run `latexindent` in-place. |
| `make check` | Lint + format check. |

Build config lives in `.latexmkrc`. The `$failure_cmd` there runs `./bin/t diagnose` on every failed build, so you always see a suggested fix.

The `$pdf_previewer` line is set up for zathura + neovim/vimtex. Comment it out or change it to match your viewer.

## Dependency management

`tex-packages.toml` declares packages (Cargo-style). The helper script `bin/t` wraps `tlmgr`:

```
./bin/t --help
```

The key commands are `restore` (install everything in the manifest), `add` (install + record), and `diagnose` (parse the build log and suggest missing packages). `diagnose` is wired into `.latexmkrc` so it runs automatically on failure.

## Fonts

The default stack is Latin Modern: it ships with every TinyTeX install so the skeleton compiles immediately. The preamble uses `fontspec` + `unicode-math` for OpenType math.

To switch fonts, edit the `\set...font` lines in `src/_preamble.tex` and install the font package. Some free options:

- Libertinus Math: `./bin/t add libertinus-fonts stix2-otf`
- New Computer Modern Math, STIX Two Math, TeX Gyre family, Erewhon Math, Fira Math

## Package stack

Declared in `tex-packages.toml`:

| Package | Purpose |
|---|---|
| `fontspec` + `unicode-math` | OTF text and math fonts |
| `mathtools` | amsmath superset |
| `physics2` | bracket/derivative macros |
| `siunitx` | units and numerical data |
| `cleveref` | smart cross-references |
| `biblatex` + `biber` | bibliography |
| `csquotes` | quotes compatible with biblatex |
| `microtype` | protrusion and font expansion |
| `booktabs` | tables |
| `tikz` + `pgfplots` | figures |

## Linting and formatting

`chktex` and `latexindent` are declared in `tex-packages.toml`, so `./bin/t restore` installs both. `latexindent` also needs four Perl modules that `tlmgr` does not ship:

```bash
cpan App::cpanminus
cpanm Log::Log4perl YAML::Tiny File::HomeDir Unicode::GCString
```

If that's not worth it, skip `make fmt` and use `make lint` alone. Configs: `.chktexrc`, `localSettings.yaml`.

## Editor setup

neovim + [vimtex](https://github.com/lervag/vimtex) is the tested setup. VimTeX reads `.latexmkrc` automatically. Useful companions: [LuaSnip](https://github.com/L3MON4D3/LuaSnip) for snippets, [texlab](https://github.com/latex-lsp/texlab) for LSP.

VS Code works with the LaTeX Workshop extension pointed at `latexmk`. Overleaf works if you mirror `_preamble.tex` and `refs.bib`, but its TeX Live version may differ.

## Reproducibility

The preamble sets `\pdfvariable suppressoptionalinfo 512` under LuaLaTeX so timestamps don't leak into the PDF. The manifest tracks package names, not versions. For byte-identical PDFs across machines, consider [Tectonic](https://tectonic-typesetting.github.io/) with a pinned bundle URL.

## License

Paper text and figures: CC BY 4.0. Code: MIT.

## Citation

```bibtex
@article{lastname2026title,
  title   = {Paper Title},
  author  = {Last, First},
  journal = {Journal},
  year    = {2026}
}
```
