# latex-vim

A LaTeX-first Neovim configuration for math coursework — lecture notes, homework,
and comprehensive solutions, written at lecture speed. Everything is tuned around
one loop: **type → autosave (debounced) → latexmk continuous build → Skim refresh**.

## Repository layout

| File | Purpose |
|------|---------|
| `init.vim` | The whole config, organized §1–§8: core settings, keymaps, plugins, theme, the VimTeX workflow, autocommands, Lua plugin setup, compatibility commands |
| `after/plugin/luasnip.lua` | Every TeX snippet (single source of truth), including homework/solutions-specific ones |
| `textemplate.tex` | Template auto-seeded into every new `.tex` buffer: LuaLaTeX preamble, shared notation macros, problem/solution machinery |
| `textemplate.pdf` | Rendered preview of the template — exactly what a new `.tex` file looks like on first compile |
| `.gitignore` | Keeps vim-plug's installed plugins and the installer out of the repo |

## Requirements

- **Neovim ≥ 0.11** (uses the native `vim.lsp.config`/`vim.lsp.enable` API; `aerial.nvim` is pinned to its `nvim-0.11` branch)
- **A LuaLaTeX toolchain** (`latexmk` + `lualatex`; macOS: `brew install --cask mactex-no-gui`)
- **Skim** (macOS PDF viewer with SyncTeX round-trips) at `/Applications/Skim.app`
- `ripgrep` (Telescope live grep)
- Optional: `chktex` (live TeX lint), `latexindent` (buffer formatting), formatters/LSP servers for other languages (`stylua`, `black`, `clang-format`, `prettier`, `clangd`, `pyright`, …) — installed via Mason

## Install

```bash
git clone git@github.com:fvdqyxm/latex-vim.git ~/.config/nvim

# vim-plug installer (not committed)
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

nvim +PlugInstall
```

Two paths are machine-specific and worth adjusting on a new machine (both near
the top of `init.vim` / in §5):

```vim
let g:python3_host_prog = "/Users/.../venv/bin/python"   " §1 — python provider
let g:jupytext_command  = '/Users/.../venv/bin/jupytext' " §5 — notebook editing
```

## The LaTeX workflow

- **Continuous compile**: opening any `.tex` file starts `latexmk` (continuous,
  `-lualatex`, SyncTeX on) after ~300 ms. Builds land **next to the `.tex`
  source** — the same location a plain `latexmk` run uses, so editor and CLI
  builds never fork two PDFs.
- **Debounced autosave**: TeX buffers save 650 ms after typing stops (or on
  leaving Insert mode), so half-typed commands never trigger a rebuild.
- **Quickfix stays closed** during background compiles; inspect errors on demand.

| Keys | Action |
|------|--------|
| `Space la` | save + compile (checkpoint) |
| `Space ll` / `Space lk` | start/refresh continuous compile / stop compiler |
| `Space lv` | open PDF in Skim (SyncTEX both directions) |
| `Space le` | inspect compiler errors |
| `Space lt` | toggle table of contents |
| `Space lm` / `Space lo` | one-shot compile / compiler output |
| `Space lc` / `Space li` | clean aux files / project info |
| `Space ts` | toggle spell checking (`en_us`, on by default in TeX) |

TeX buffers also get `wrap linebreak breakindent`, `textwidth=88`, and
`colorcolumn=89` so prose wraps where the PDF does.

### Insert-mode triggers

| Trigger | Expands to |
|---------|-----------|
| `;b` / `;i` | `\textbf{}` / `\emph{}` (cursor inside) |
| `;c` / `;p` / `;r` | new paragraph labeled *Claim.* / *Proof.* / *Remark.* |
| `\(` / `\[` | inline / display math pair, cursor inside |

### Snippets (Tab to expand)

Homework & solutions flow:

| Trigger | Expands to |
|---------|-----------|
| `hw` | `\exercise{8.6}` header + solution block (comprehensive solutions files) |
| `hwp` | auto-numbered `\subsubsection*{Problem N}` + solution (number is computed from the Problem headers already in the buffer) |
| `chb` | `\chapterbanner{n}{title}{subtitle}` (comprehensive solutions files) |
| `claim` | italic *Claim.* + matched amsthm `proof` (auto `\qed`, nests inside solutions) |
| `prb` / `prob` | problem statement (+ solution) block |
| `sol` / `ans` | solution / answer block (proof-based, auto `\qed`) |

Theorem-style notes: `defn`, `thm`, `lem`, `prop`, `cor`, `ex`, `rem`, `proof`.
Display & layout: `al`, `eq`, `cases`, `mat`, `m22`–`m33` (matrix grids),
`tm22`/`tm33` (transition matrices), `enum`, `item`, `sec`, `ssec`.
Shorthand: `rr`/`cc`/`qq`/`zz`/`nn`/`ff` (number sets), `abs`, `norm`, `ip`,
`set`, `span`, `rank`, `ker`, `im`, `hom`, `aut`, `ord`, `pd`, `dv`, `lim`,
`eps`, `lto`, `ft`, `fourier`, `laplace`, `int`, `pset`, `cond`, `ev`, `var`,
`cov`, `indep`, `iid`, `given`.

Completion in TeX prioritizes **vimtex** (commands, labels, refs, citations) and
**LaTeX symbols** (type `\alpha`-ish names, get the glyph), then snippets,
buffer words, and paths.

## Templates & notation

Every new `.tex` buffer is seeded from `textemplate.tex`, which defines the same
notation macros used by the coursework templates (`\R \Z \Q \N \C \F \E \Prob`,
`\abs \norm \ip \set \ceil \floor \given \indep \wh \deriv \pderiv \dd \eps`,
operators `\Span \rank \nullity \Ker \im \Hom \Aut \End \Gal \ord \tr \Var \Cov
\argmin \argmax`, …) plus `problem`/`solution`/`answer`, `claim`/`idea`/
`proofsketch`, and the quick `\exercise{n}` header. Muscle memory transfers
across scratch files, lecture notes, homework, and solutions files.
See **[textemplate.pdf](textemplate.pdf)** for exactly what a fresh file
renders as.

## Companion coursework repository

This config pairs with a private coursework repo organized per class
(`math104/ … stat150/`), each containing:

- `lectures/lecture_NN.tex` — scaffolded by `new_lecture_note.sh`
- `homework/hwNN_sol.tex` — scaffolded by `new_homework.sh` (problem count
  auto-detected from the assignment PDF; a pasted Fraleigh-style list becomes
  the problem headers verbatim)
- `solutions.tex` — one comprehensive per-chapter solutions document with
  `\chapterbanner` per textbook chapter and `\exercise{n}` entries
- `sync.sh` — builds changed files, regenerates the README as a clickable index
  of **completed work only** (untouched scaffolds are detected and hidden),
  then commits and pushes.

## General editing

| Keys | Action |
|------|--------|
| `jk` | leave Insert mode |
| `Space w` / `Space q` / `Space Q` | save / quit / quit-all |
| `Ctrl-h/j/k/l` | move between splits (also from terminal mode) |
| `Space sv/sh/se/sx` | split / equalize / close |
| `Space ,` / `Space .` | swap the focused code pane left / right |
| `Space 1–9`, `Space t*`, `Ctrl-Tab` | tabs |
| `S-h` / `S-l` | previous / next buffer |
| `Space e` / `Space o` | toggle / focus the file tree |
| `Space ff/fg/fb/fr/fh` | Telescope: files / grep / buffers / old files / help |
| `Space fs/fS/ss/sr/sm/si` | symbols (document / workspace / references / mentions) |
| `Space xx/xq/xl/xs` | Trouble: diagnostics / quickfix / loclist / symbols |
| `Space so` | aerial structure outline |
| `Space cf` / `Space lx` | format buffer (conform) / run lint (nvim-lint) |
| `Space zw` | Goyo distraction-free writing (with vim-pencil for Markdown) |
| `Ctrl-c` | toggle comment (normal/visual) |

LSP (clangd, pyright, jdtls, lua_ls, bashls, jsonls, marksman): `gd`, `gD`,
`gr`, `gi`, `K`, `Space rn` (rename), `Space ca` (code action), `Space lf`
(format), `[d`/`]d` (diagnostic jump). clangd additionally gets inlay hints and
`Space ch` for header/source switching; `classlayout.nvim` shows C/C++ memory
layouts (`Space cl`); `cmake-tools.nvim` drives CMake projects (`Space c*`).

Treesitter is installed for many languages but **highlighting is intentionally
off** — Vim's regex syntax (and VimTeX for TeX) is the preferred engine;
treesitter provides indentation, text objects (`af`/`if`/`ac`/`ic`/`ab`/`ib`),
and the aerial backend.
