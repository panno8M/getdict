import std/httpclient
import std/htmlparser
import std/parseopt
import std/strutils
import std/xmltree
import std/strformat


template dump(contents) =
  echo "TOTAL: ", contents.len
  var i {.gensym.} : int
  for c in contents:
    echo "+====+"
    echo "| #", i, " |"
    echo "+====+"
    echo ""

    echo c

    inc i


var popt = initOptParser()

var searchTexts: seq[string]

while true:
  popt.next()
  case popt.kind
  of cmdEnd:
    break
  of cmdShortOption, cmdLongOption:
    discard
  of cmdArgument:
    searchTexts.add popt.key
    

var client = newHttpClient()
let htmltext = client.getContent("https://dictionary.cambridge.org/dictionary/learner-english/" & searchTexts.join("-"))

let html = htmltext.parsehtml()

let htmlbody = html[1][3]

let contents =
  htmlbody[7][7][1][3][1][3][1][3][3][37][6][0][0]


var contentsByParts: seq[XmlNode]

for c in contents:
  if c.kind != xnElement: continue
  if c.attr("class") == "pr entry-body__el":
    contentsByParts.add c


for p in contentsByParts.mitems:
  p = p[2]
  for i in countdown(p.len-1, 0):
    if p[i].kind != xnElement:
      p.delete(i)

  for m in p.mitems:
    for i in countdown(m.len-1, 0):
      if m[i].kind != xnElement or m[i].attr("class") == "cid":
        m.delete(i)
    



for p in contentsByParts:
  echo p
