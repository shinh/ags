require 'handler'

class Check < Handler
  def handle_
    puts %Q(
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
 <meta http-equiv="CONTENT-TYPE" content="text/html; charset=UTF-8">
 <title>Checker</title>
 <link rev="MADE" href="mailto:shinichiro.hamaji _at_ gmail.com">
 <link rel="INDEX" href=".">
 <link rel="stylesheet" type="text/css" href="/site.css">
</head>

<script>
use_form = function() {
  document.getElementById('file').innerHTML='<select name="ext">#{sorted_langs.map{|x, y|"<option value=\"#{x}\">#{y}</option>"}}</select><br><textarea name="code" rows="20" cols="80"></textarea>';
  return false;
}
</script>

<body>

<h1>Checker</h1>

<p>
You can check the performance of your program here.
The timeout of this interface is 10 seconds.

<p>
<form action="checker.rb" method="POST" enctype="multipart/form-data">
<div id="file">
File: <input type="file" name="file"> <input type="button" onclick="use_form(); 1;" value="use form"><br>
</div>
Input:<br>
<textarea name="input" rows="10" cols="60"></textarea><br>
<input type="submit"><br>
</form>

</body></html>
)
  end
end
