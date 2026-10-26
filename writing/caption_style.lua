-- Figure and graphical-abstract captions use ReportCaption (below the figure).
-- Table captions use ReportTableCaption (above the table: kept with the table
-- and separated from the table before it). Paragraphs that only hold a picture
-- use ReportFigure, which keeps the picture on the same page as its caption.
-- Short tables (at most 30 rows) get TableKeep text in every row but the last, so
-- Word keeps them on one page. The styles are defined in docx_template.docx.
function Para(el)
  local text = pandoc.utils.stringify(el)
  if text:match("^%s*Table%s+[%w]+%.") then
    return pandoc.Div({el}, pandoc.Attr("", {}, { ["custom-style"] = "ReportTableCaption" }))
  end
  if text:match("^%s*Figure%s+[%w]+%.") or
     text:match("^%s*Graphical abstract%.") then
    return pandoc.Div({el}, pandoc.Attr("", {}, { ["custom-style"] = "ReportCaption" }))
  end
  if #el.content == 1 and el.content[1].t == "Image" then
    return pandoc.Div({el}, pandoc.Attr("", {}, { ["custom-style"] = "ReportFigure" }))
  end
  return el
end

local attr = pandoc.Attr("", {}, { ["custom-style"] = "TableKeep" })
local function keep_row(row)
  for _, cell in ipairs(row.cells) do
    local blocks = pandoc.List()
    for _, b in ipairs(cell.contents) do
      if b.t == "Plain" or b.t == "Para" then blocks:insert(pandoc.Div({pandoc.Para(b.content)}, attr)) else blocks:insert(b) end
    end
    cell.contents = blocks
  end
  return row
end
function Table(tbl)
  local n = #tbl.head.rows
  for _, body in ipairs(tbl.bodies) do n = n + #body.body end
  if n > 30 then return tbl end   -- longer tables flow over pages normally
  local head = tbl.head
  local hrows = head.rows
  for i = 1, #hrows do hrows[i] = keep_row(hrows[i]) end
  head.rows = hrows; tbl.head = head
  local bodies = tbl.bodies
  for _, body in ipairs(bodies) do
    local rows = body.body
    for j = 1, #rows - 1 do rows[j] = keep_row(rows[j]) end
    body.body = rows
  end
  tbl.bodies = bodies
  return tbl
end

-- A table inside a div with class "allow-page-break" (::: {.allow-page-break}) may flow over pages even when it
-- has at most 30 rows: tables with tall, wrapped rows (e.g. Table S9) cannot fit one page, and keeping them
-- together pushes the whole table to a new page and leaves the page before it nearly empty. The Table filter has
-- already run on the child table (bottom-up traversal), so its TableKeep wrappers are removed here.
function Div(el)
  if el.classes:includes("allow-page-break") then
    -- keep_row() turned each cell's Plain into a Para inside the TableKeep div; restore the Plain so the cell keeps
    -- the template's compact table style (a bare Para would be set as body text)
    return el:walk({ Div = function(d)
      if d.attr.attributes["custom-style"] == "TableKeep" then
        local out = pandoc.List()
        for _, b in ipairs(d.content) do
          if b.t == "Para" then out:insert(pandoc.Plain(b.content)) else out:insert(b) end
        end
        return out
      end
    end })
  end
end
