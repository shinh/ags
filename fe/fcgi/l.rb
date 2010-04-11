require 'handler'

class L < Handler
  def handle_
    html_header
    pn, pa = page
    lindex = file_types.index(pa)
    if !lindex && !pa.empty?
      puts 'page not found'
      foot
      return
    end

    title("anarchy golf - Results by a language")
    puts "<h1>Results by a language</h1>"
    put_by_languages(pa, 'l.rb')

    if pa.empty?
      foot
      return
    end

    puts "<h2>#{file_langs[lindex]}</h2>"

    puts %Q(name grep: <input type="text" id="namegrep" size="14" value=")+user_name+%Q(" onkeypress="if (event.keyCode == 10 || event.keyCode == 13) {display();}">
max results: <input type="text" id="nresults" size="4" value="3" onkeypress="if (event.keyCode == 10 || event.keyCode == 13) {display();}">
<input type="button" onClick="display()" value="Update">
<div id="ldata"><div>)

    if !$l_ranks
      $l_ranks = {}
    end
    r = $l_ranks[pa]
    nowt = Time.now
    now = nowt.to_i
    if !r || r[0] < now
      html = ''

      problem_db.get('root').each do |p|
        ldb = PStore.new("db/#{p}/_ranks.db")

        dl = get_db(p).get('deadline').to_i
        pm = (dl > 0 && dl < now) ? 1 : 0

        r = ldb.transaction(true) do
          ldb[pa]
        end
        html += "<h2>#{problem_summary(p, dl, now)}</h2>"
        if r
          html += lranking(pa,r,p,nil,pm)
        else
          html += 'No entries.'
        end
      end

      html += tag('p', "Last update: #{nowt.getutc} (#{nowt})")

      r = [now+10*60, html]
      $l_ranks[pa] = r
    end

    puts r[1]

    puts %Q(</div></div>

<script type="text/javascript"><!--
var orig=document.getElementById("ldata").cloneNode(true);
function nameGrep(row,un) {
    var cell = row.childNodes.item(1).firstChild;
    if (!cell) return false;
    var n = null;
    if (cell.tagName == "A") { n = cell.text || cell.innerText }
    else { n = cell.nodeValue }
    return n.indexOf(un)!=-1;
}
function display()
{
    var t=document.getElementById("ldata");
    t.replaceChild(orig.firstChild, t.firstChild);
    orig=document.getElementById("ldata").cloneNode(true);
    var ldata = document.getElementsByTagName("table");

    var nrows= (+document.getElementById("nresults").value)||10000;
    var name= document.getElementById("namegrep").value||"kafsdkszfak";

    for(i=0;i<ldata.length;i++) {

        for(j=ldata.item(i).rows.length-1;j>nrows;j--) {
            if (!nameGrep(ldata.item(i).rows.item(j),name)) {
                ldata.item(i).deleteRow(j);
            }
        }

        for(j=0;j<ldata.item(i).rows.length;j++) {
            if (nameGrep(ldata.item(i).rows.item(j),name)) {
                ldata.item(i).rows.item(j).style.fontWeight = 'bold';
            }
        }
    }
}
//display();
//--></script>)

    foot
  end
end
