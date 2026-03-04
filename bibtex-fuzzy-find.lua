local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")

-- In-memory cache keyed by TeX file path
-- value = { entries = {...}, bib_files = {...}, mtimes = { [path]=mtime }, last_loaded = os.time() }
local CACHE = {}

-- Util: case-insensitive pattern for field names
local function ci(name)
  return (name:gsub("%a", function(c)
    return string.format("[%s%s]", c:lower(), c:upper())
  end))
end

local function clean_value(s)
  if not s then return "" end
  return (s
    :gsub("[\r\n]", " ")
    :gsub("[{}\"]", " ")
    :gsub("%s+", " ")
    :gsub("^%s+", "")
    :gsub("%s+$", ""))
end

-- Resolve addbibresource paths relative to the given TeX file
local function get_bib_files_for(tex_file)
  local bib_files = {}
  if not tex_file or tex_file == "" then return bib_files end
  local tex_dir = vim.fn.fnamemodify(tex_file, ":h")

  for line in io.lines(tex_file) do
    local path = line:match("\\addbibresource%s*{%s*(.-)%s*}")
    if path then
      path = path:gsub('^["{ ]*', ""):gsub('["} ]*$', "")
      local abs_path = vim.fn.fnamemodify(tex_dir.. "/".. path, ":p")
      if vim.fn.filereadable(abs_path) == 1 then
        table.insert(bib_files, abs_path)
      end
    end
  end
  return bib_files
end

-- Robust BibTeX entry parser (supports @type{...} and @type(...))
local function parse_bib_entries(bibfile)
  local entries = {}

  local current = nil
  local level = 0
  local closing = nil  -- '}' or ')'

  local function n_char(s, ch)
    local _, cnt = s:gsub(ch, "")
    return cnt
  end

  local function start_entry(line)
    if not line:find("^%s*@") then return false end
    local delim = line:match("^%s*@[%a]+%s*([%({])")
    if not delim then return false end
    closing = (delim == "{") and "}" or ")"
    level = n_char(line, delim) - n_char(line, closing)
    current = {
      raw_lines = { line },
      header = line,
      entrytype = (line:match("^%s*@([%a]+)") or ""):lower(),
    }
    return true
  end

  local function finalize_entry()
    if not current then return end
    local text = table.concat(current.raw_lines, "\n")

    -- Extract key from header
    local key =
      current.header:match("^%s*@[%a]+%s*%{%s*([^,=%s]+)") or
      current.header:match("^%s*@[%a]+%s*%(%s*([^,=%s]+)") or
      ""

    local TITLE = ci("title")
    local AUTHOR = ci("author")

    local title = text:match(TITLE.. "%s*=%s*{(.-)}")
               or text:match(TITLE.. "%s*=%s*\"(.-)\"")
    local author = text:match(AUTHOR.. "%s*=%s*{(.-)}")
                or text:match(AUTHOR.. "%s*=%s*\"(.-)\"")

    table.insert(entries, {
      key = key,
      entrytype = current.entrytype,
      title = clean_value(title),
      author = clean_value(author),
      raw_lines = current.raw_lines,
    })

    current, level, closing = nil, 0, nil
  end

  for raw in io.lines(bibfile) do
    if not current then
      start_entry(raw)
    else
      table.insert(current.raw_lines, raw)
      local open_ch = (closing == "}") and "{" or "("
      level = level + n_char(raw, open_ch) - n_char(raw, closing)
      if level <= 0 then
        finalize_entry()
      end
    end
  end

  if current then
    finalize_entry()
  end

  return entries
end

-- Cache helpers
local function mtimes_for(paths)
  local mt = {}
  for _, p in ipairs(paths) do
    mt[p] = vim.fn.getftime(p) or 0
  end
  return mt
end

local function mtimes_equal(a, b)
  for k, v in pairs(a or {}) do
    if not b or b[k] ~= v then return false end
  end
  for k, v in pairs(b or {}) do
    if not a or a[k] ~= v then return false end
  end
  return true
end

local function rebuild_cache(tex_file, bib_files)
  local collected = {}
  for _, bibfile in ipairs(bib_files) do
    local ok, entries = pcall(parse_bib_entries, bibfile)
    if ok and entries then
      for _, e in ipairs(entries) do
        if e.entrytype ~= "string" and e.entrytype ~= "preamble" and e.entrytype ~= "comment" then
          table.insert(collected, e)
        end
      end
    else
      vim.notify("Failed to parse ".. bibfile, vim.log.levels.WARN)
    end
  end
  CACHE[tex_file] = {
    entries = collected,
    bib_files = bib_files,
    mtimes = mtimes_for(bib_files),
    last_loaded = os.time(),
  }
  return collected
end

local function get_cached_entries(tex_file)
  local c = CACHE[tex_file]
  if not c then return nil end
  if not mtimes_equal(c.mtimes, mtimes_for(c.bib_files)) then
    return nil
  end
  return c.entries
end

-- Public: preload for current buffer (call from autocmd)
function M.preload_for_tex(tex_file)
  if not tex_file or tex_file == "" then return end
  local bib_files = get_bib_files_for(tex_file)
  if #bib_files == 0 then return end

  local cached = get_cached_entries(tex_file)
  if cached then
    return
  end

  vim.schedule(function()
    local entries = rebuild_cache(tex_file, bib_files)
    vim.notify(string.format("Bib cache ready (%d entries)", #entries), vim.log.levels.INFO)
  end)
end

-- Public: picker (uses cached entries, rebuilds if missing/stale)
function M.telescope_cite_picker()
  local tex_file = vim.fn.expand("%:p")
  if tex_file == "" then
    vim.notify("Open a TeX file first", vim.log.levels.WARN)
    return
  end

  local bib_files = get_bib_files_for(tex_file)
  if #bib_files == 0 then
    vim.notify("No \\addbibresource files found", vim.log.levels.INFO)
    return
  end

  local entries = get_cached_entries(tex_file)
  if not entries then
    -- Synchronously rebuild if not preloaded; first run may take a bit
    vim.notify("Building Bib cache...", vim.log.levels.INFO)
    entries = rebuild_cache(tex_file, bib_files)
  end

  pickers.new({}, {
    prompt_title = "BibTeX",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(e)
        local title = (e.title ~= "" and e.title) or "[no title]"
        local display = string.format("%s — %s", e.key, title)
        -- Keep original case; put title first to prioritize title matches
        local ordinal = (title.. " ".. e.key.. " ".. (e.author or ""))
        return {
          value = e,
          display = display,
          ordinal = ordinal,
        }
      end
    }),
    -- Use generic sorter so fzf-native can override if enabled; otherwise default is fine
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, _)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value.raw_lines)
      end
    }),
    attach_mappings = function(_, _)
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local cite = string.format("\\cite{%s}", selection.value.key)
        vim.api.nvim_put({ cite }, "c", true, true)
      end)
      return true
    end,
  }):find()
end

return M
