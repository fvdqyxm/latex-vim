-- LaTeX snippets for homework and course notes.
local ok, ls = pcall(require, "luasnip")
if not ok then
  return
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function matrix_snippet(trigger, rows, cols, symbol, transition)
  local placeholders = {}
  local lines = {}
  local node_index = 1

  for row = 1, rows do
    local cells = {}
    for col = 1, cols do
      cells[#cells + 1] = "{}"
      placeholders[#placeholders + 1] = i(
        node_index,
        string.format("%s_{%d%d}", symbol, row, col)
      )
      node_index = node_index + 1
    end
    lines[#lines + 1] = table.concat(cells, " & ")
  end

  local body = "\\begin{{bmatrix}}\n"
    .. table.concat(lines, " \\\\\n")
    .. "\n\\end{{bmatrix}}"
  if transition then
    body = "P = " .. body .. "\\qquad \\sum_j p_{{ij}} = 1"
  end

  return s(trigger, fmt(body, placeholders))
end

ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})

local function env(name, title, label, body)
  return fmt(string.format([[
\begin{{%s}}[{}]
\label{{%s:{}}}
{}
\end{{%s}}
]], name, label, name), {
    i(1, title),
    i(2, "label"),
    i(3, body),
  })
end

-- Next homework problem number: scan the buffer from the top through the
-- cursor's line for existing "Problem N" headers; return the largest N + 1.
local function next_problem_number()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, 0, 0, math.max(cursor_line, 1), false)
  if not ok or not lines then
    return 1
  end
  local best = 0
  for _, line in ipairs(lines) do
    local n = line:match("\\subsubsection%*%s*{Problem%s+(%d+)")
    if n then
      n = tonumber(n) or 0
      if n > best then best = n end
    end
  end
  return best + 1
end

ls.add_snippets("tex", {
  -- Problems and solutions.
  -- "hw": solutions-file flow — exercise header + solution block.
  s("hw", fmt([[
\exercise{{{}}}
\begin{{solution}}
  {}
\end{{solution}}
]], { i(1, "8.6"), i(2, "Solution") })),
  -- Homework-file flow: auto-numbered "Problem N" header + solution block.
  -- N is computed at expansion time from the Problem headers above the cursor.
  s("hwp", {
    f(function()
      return string.format("\\subsubsection*{Problem %d}", next_problem_number())
    end),
    t({ "", "", "\\begin{solution}", "" }),
    i(1),
    t({ "", "\\end{solution}" }),
  }),
  -- "claim": clean claim + proof pair — italic Claim label, then an amsthm
  -- proof (italic label, auto \qed, nests fine inside solution/answer).
  s("claim", {
    t("\\noindent\\textit{Claim.} "),
    i(1, "statement"),
    t({ "", "", "\\begin{proof}", "" }),
    i(2, "argument"),
    t({ "", "\\end{proof}" }),
  }),
  -- "chb": chapter banner for the per-course solutions files.
  s("chb", fmt([[
\chapterbanner{{{}}}{{{}}}{{{}}}
]], { i(1, "2"), i(2, "Chapter title"), i(3, "Ross, \\S\\S 7--16") })),
  s("prb", fmt([[
\begin{{problem}}[{}]
\label{{prob:{}}}
{}
\end{{problem}}

\begin{{solution}}
{}
\end{{solution}}
]], { i(1, "Short title"), i(2, "label"), i(3, "Problem statement"), i(4, "Solution") })),
  s("prob", fmt([[
\begin{{problem}}[{}]
\label{{prob:{}}}
{}
\end{{problem}}
]], { i(1, "Short title"), i(2, "label"), i(3, "Problem statement") })),
  s("sol", fmt([[
\begin{{solution}}
{}
\end{{solution}}
]], { i(1, "Solution") })),
  s("ans", fmt([[
\begin{{answer}}
{}
\end{{answer}}
]], { i(1, "Answer") })),

  -- Theorem-style notes.
  s("defn", env("definition", "Name", "def", "Definition")),
  s("thm", env("theorem", "Optional title", "thm", "Theorem")),
  s("lem", env("lemma", "Optional title", "lem", "Lemma")),
  s("prop", env("proposition", "Optional title", "prop", "Proposition")),
  s("cor", env("corollary", "Optional title", "cor", "Corollary")),
  s("ex", env("example", "Optional title", "ex", "Example")),
  s("rem", env("remark", "Optional title", "rem", "Remark")),
  s("proof", fmt([[
\begin{{proof}}
{}
\end{{proof}}
]], { i(1, "Proof") })),

  -- Display math and structure.
  s("al", fmt([[
\begin{{align*}}
{}
\end{{align*}}
]], { i(1) })),
  s("eq", fmt([[
\begin{{equation*}}
{}
\end{{equation*}}
]], { i(1) })),
  s("cases", fmt([[
\begin{{cases}}
{}
\end{{cases}}
]], { i(1, "x, & \\text{if } \\ldots") })),
  s("mat", fmt([[
\begin{{bmatrix}}
{}
\end{{bmatrix}}
]], { i(1, "a & b \\\\ c & d") })),
  matrix_snippet("m22", 2, 2, "a", false),
  matrix_snippet("m23", 2, 3, "a", false),
  matrix_snippet("m32", 3, 2, "a", false),
  matrix_snippet("m33", 3, 3, "a", false),
  matrix_snippet("tm22", 2, 2, "p", true),
  matrix_snippet("tm33", 3, 3, "p", true),
  s("enum", fmt([[
\begin{{enumerate}}
  \item {}
\end{{enumerate}}
]], { i(1) })),
  s("item", fmt([[
\begin{{itemize}}
  \item {}
\end{{itemize}}
]], { i(1) })),
  s("sec", fmt([[
\section{{{}}}
{}
]], { i(1, "Section title"), i(2) })),
  s("ssec", fmt([[
\subsection{{{}}}
{}
]], { i(1, "Subsection title"), i(2) })),

  -- Abstract algebra and linear algebra.
  s("rr", t("\\mathbb{R}")),
  s("cc", t("\\mathbb{C}")),
  s("qq", t("\\mathbb{Q}")),
  s("zz", t("\\mathbb{Z}")),
  s("nn", t("\\mathbb{N}")),
  s("ff", t("\\mathbb{F}")),
  s("norm", fmt([[\norm{{{}}}]], { i(1) })),
  s("abs", fmt([[\abs{{{}}}]], { i(1) })),
  s("ip", fmt([[\ip{{{}}}{{{}}}]], { i(1, "u"), i(2, "v") })),
  s("set", fmt([[\set{{{}}}]], { i(1) })),
  s("span", fmt([[\Span{{{}}}]], { i(1) })),
  s("rank", fmt([[\rank{{{}}}]], { i(1) })),
  s("null", fmt([[\nullity{{{}}}]], { i(1) })),
  s("ker", fmt([[\Ker{{{}}}]], { i(1) })),
  s("im", fmt([[\im{{{}}}]], { i(1) })),
  s("hom", fmt([[\Hom({})]], { i(1) })),
  s("aut", fmt([[\Aut({})]], { i(1) })),
  s("ord", fmt([[\ord({})]], { i(1) })),

  -- Real/Fourier analysis.
  s("pd", fmt([[\frac{{\partial {}}}{{\partial {}}}]], { i(1, "f"), i(2, "x") })),
  s("dv", fmt([[\frac{{d {}}}{{d {}}}]], { i(1, "f"), i(2, "x") })),
  s("lim", fmt([[\lim_{{{} \to {}}} {}]], { i(1, "x"), i(2, "\\infty"), i(3) })),
  s("eps", t("\\varepsilon")),
  s("lto", t("\\longrightarrow")),
  s("ft", fmt([[\wh{{{}}}]], { i(1, "f") })),
  s("fourier", t("\\Fourier")),
  s("laplace", t("\\Laplace")),
  s("int", fmt([[\int_{{{}}}^{{{}}} {} \\dd {}]], { i(1, "a"), i(2, "b"), i(3, "f(x)"), i(4, "x") })),

  -- Stochastic processes and probability.
  s("pset", fmt([[\Prob\set{{{}}}]], { i(1, "A") })),
  s("cond", fmt([[\Prob(A \\given B)]], {})),
  s("ev", fmt([=[\E[{}]]=], { i(1, "X") })),
  s("var", fmt([[\Var({})]], { i(1, "X") })),
  s("cov", fmt([[\Cov({},{})]], { i(1, "X"), i(2, "Y") })),
  s("indep", t("\\indep")),
  s("iid", t("\\text{i.i.d.}")),
  s("given", t("\\given")),

  -- Useful matrix helper for analysis notes.
  s("hmat", {
    t("\\begin{bmatrix} "), i(1, "f_{xx}"), t(" & "), i(2, "f_{xy}"),
    t(" \\\\ "), i(3, "f_{yx}"), t(" & "), i(4, "f_{yy}"),
    t(" \\end{bmatrix}"),
  }),
  s("nhess", {
    t("H_f = "),
    f(function(args)
      local n = tonumber(args[1][1]) or 2
      local rows = {}
      for row = 1, n do
        local cols = {}
        for col = 1, n do
          cols[#cols + 1] = "\\frac{\\partial^2 f}{\\partial x_" .. row .. " \\partial x_" .. col .. "}"
        end
        rows[#rows + 1] = table.concat(cols, " & ")
      end
      return "\\begin{bmatrix} " .. table.concat(rows, " \\\\ ") .. " \\end{bmatrix}"
    end, { 1 }),
    t(" "), i(1, "2"),
  }),
})
