<?php

if( !function_exists('str_split') )
{
    function str_split($string, $split_length=1)
    {
        $array = array();
        $len = strlen($string);
        do
        {
            $part = '';
            for ($j = 0; $j < $split_length; $j++)
            {
                $part .= $string{$i};
                $i++;
            }
            $array[] = $part;
        }
        while ($i < $len);
        return $array;
    }
}

class flogback {
  var $code;
  function flogback($x) {
    $this->code=$x;
  }
  function call($x) {
    global $thestack;
    $thestack[]=unserialize(serialize($x)); //if you don't do this it crashes
    execcode($this->code);
    return array_pop($thestack);
  }
}

function array_repeat($a,$c) {
  $o=array();
  while($c--) $o=array_merge($o,$a);
  return $o;
}

function array_implode($glue,$pieces) {
  $o=array();
  foreach($pieces as $k=>$v) {
    $o=array_merge($o,(array)$v);
    if($k!=count($pieces)-1) $o=array_merge($o,(array)$glue);
  }
  return $o;
}

function array_zip($a) {
  $o=array();
  if(count($a)==0) return $o;
  foreach($a[0] as $k=>$v) {
    $o[$k]=array();
    foreach($a as $K=>$V) {
      $o[$k][$K]=$V[$k];
    }
  }
  return $o;
}

function array_tuples($a) {
  $o=array();
  $x=array_fill(0,count($a),0);
  while(1) {
    $o1=array();
    foreach($a as $k=>$v) $o1[$k]=$v[$x[$k]];
    $o[]=$o1;
    for($k=0;$k<=count($x);$k++) {
      if($k==count($x)) return $o;
      if(count($a[$k])==++$x[$k]) $x[$k]=0; else break;
    }
  }
}

function array_tuples_callback($a,$f) {
  global $thestack;
  $x=array_fill(0,count($a),0);
  while(1) {
    $o1=array();
    foreach($a as $k=>$v) $o1[$k]=$v[$x[$k]];
    $thestack[]=$o1;
    execcode($f);
    for($k=0;$k<=count($x);$k++) {
      if($k==count($x)) return 0;
      if(count($a[$k])==++$x[$k]) $x[$k]=0; else break;
    }
  }
}

function mark_stack() {
  global $thestack;
  global $stackmark;
  $stackmark[]=count($thestack);
}

function end_mark_stack() {
  global $thestack;
  global $stackmark;
  $thestack[]=array_splice($thestack,array_pop($stackmark));
}

function almost_execute($f) {
  global $thestack;
  global $stackmark;
  global $vars;
  $my_thestack=$thestack;
  $my_stackmark=$stackmark;
  $my_vars=$vars;
  execcode($f);
  $out=array_pop($thestack);
  $thestack=$my_thestack;
  $stackmark=$my_stackmark;
  $vars=$my_vars;
  return $out;
}

function maybe_execute($f) {
  global $thestack;
  global $stackmark;
  global $vars;
  $my_thestack=$thestack;
  $my_stackmark=$stackmark;
  $my_vars=$vars;
  if(execcode($f)) {
    $thestack=$my_thestack;
    $stackmark=$my_stackmark;
    $vars=$my_vars;
    return 1;
  } else {
    return 0;
  }
}

function str_expand_special($s) {
  global $thestack;
  global $vars;
  $out="";
  for($i=0;$i<strlen($s);$i++) {
    $c=$s[$i];
    if($c=='\\') $c.=$s[++$i];
    switch($c) {
      case '\\n': $out.="\n"; break;
      case '\\r': $out.="\r"; break;
      case '\\t': $out.="\t"; break;
      case '\\v': $out.="\v"; break;
      case '\\f': $out.="\f"; break;
      case '\\C': $out.="{"; break;
      case '\\D': $out.="}"; break;
      case '\\0': $out.=chr(0); break;
      case ':':
        $c=ord($s[++$i]); $d=ord($out[strlen($out)-1]);
        if($c>$d) {
          for($d++;$d<=$c;$d++) $out.=chr($d);
        } else {
          for($d--;$d>=$c;$d--) $out.=chr($d);
        }
        break;
      case '<':
        $d=strpos($c=substr($s,++$i),'>');
        if(!$d) {$c='_';$d++;}
        $i+=$d;
        $out.=$vars[substr($c,0,$d)];
        break;
      case '|': $out.=array_pop($thestack); break;
      case '?':
        if(array_pop($thestack)) $i++;
        break;
      case '!':
        if(!array_pop($thestack)) $i++;
        break;
      case '$':
        $d=hexdec(substr($s,++$i,2));
        $i++;
        $out.=chr($d);
        break;
      case '*':
        $d=hexdec(substr($s,++$i,2));
        $i++;
        $out.=str_repeat($out[strlen($out)-1],$d);
        break;
      case '[':
        $d=hexdec(substr($s,++$i,2));
        $i++;
        $out.=substr($out,0,$d);
        break;
      case ']':
        $d=hexdec(substr($s,++$i,2));
        $i++;
        $out.=substr($out,strlen($out)-$d);
        break;
      case '{': //reserved
      case '}': //reserved
      case '^': //reserved
        break;
      default:
        if($c[0]=='\\') $out.=$c[1]; else $out.=$c;
    }
  }
  return $out;
}

function brainfuck($c,$s) {
  global $thestack,$stdinput;
  $p=0; $reg=0;
  for($i=0;$i<strlen($c);$i++) {
    if(ctype_digit($c{$i})) $s[$p]=chr((ord($s[$p])*16+$c{$i})&255);
    if(ctype_xdigit($c{$i}) && ctype_upper($c{$i})) $s[$p]=chr((ord($s[$p])*16+ord($c{$i})-55)&255);
    if($c{$i}=='+') $s[$p]=chr((ord($s[$p])+1)%256);
    if($c{$i}=='-') $s[$p]=chr((ord($s[$p])+255)%256);
    if($c{$i}=='<') $p--;
    if($c{$i}=='>') $p++;
    if($c{$i}==',') $s[$p]=fgetc($stdinput);
    if($c{$i}=='.') echo $s[$p];
    if($c{$i}=='[') if(!ord($s[$p])) {
      $j=1;
      while($j>0) {
        $i++;
        if($c{$i}=='[') $j++;
        if($c{$i}==']') $j--;
      }
    }
    if($c{$i}==']') if(ord($s[$p])) {
      $j=1;
      while($j>0) {
        $i--;
        if($c{$i}==']') $j++;
        if($c{$i}=='[') $j--;
      }
    }
    if($c{$i}=='i') $s=substr($s,0,$p).chr(0).substr($s,$p);
    if($c{$i}=='d') $s=substr($s,0,$p).substr($s,$p+1);
    if($c{$i}=='!') $s[$p]=chr($reg);
    if($c{$i}=='?') $reg=ord($s[$p]);
    if($c{$i}==';') $s[$p]=chr(array_pop($thestack));
    if($c{$i}==':') $thestack[]=ord($s[$p]);
    if($c{$i}=='a') $s[$p]=chr((ord($s[$p])+$reg)%256);
    if($c{$i}=='s') $s[$p]=chr((ord($s[$p])+256-$reg)%256);
    if($c{$i}=='#') $thestack[]=0;
    if($c{$i}=='p') $thestack[]=$p;
    if($c{$i}=='P') $p=array_pop($thestack);
    if($c{$i}=='l') $thestack[]=substr($s,0,$p);
    if($c{$i}=='r') $thestack[]=substr($s,$p);
    if($c{$i}=='L') $s=substr($s,0,$p);
    if($c{$i}=='R') {$s=substr($s,$p); $p=0;}
    if($c{$i}=='~') execcode(array_pop($thestack));
    if($c{$i}=='`') $s[$p]=$c{++$i};
    if($c{$i}=='"') {
      while($c{++$i}!='"') $s[$p++]=$c{$i};
    }
    if($c{$i}=="'") {
      while($c{++$i}!='"') {$s=substr($s,0,$p).$c{$i}.substr($s,$p); $p++;}
    }
    if($p==-1) {
      $p=0;
      $s=chr(0).$s;
    }
  }
  return array($s,$p);
}

function matrix_add($x,$y) {
  global $thestack;
  if(is_array($x) && is_array($y)) {
    $o=array();
    foreach($x as $k=>$v) $o[]=matrix_add($v,$y[$k]);
    return $o;
  } else if(is_int($x) && is_int($y)) {
    return $x+$y;
  } else if(is_int($x) && is_array($y)) {
    $o=array();
    foreach($y as $v) $o[]=$v+$x;
    return $o;
  } else if(is_array($x) && is_int($y)) {
    $o=array();
    foreach($x as $v) $o[]=$v+$y;
    return $o;
  } else if(is_string($x)) {
    $thestack[]=$y;
    execcode($x);
    return array_pop($thestack);
  } else if(is_string($y)) {
    $thestack[]=$x;
    execcode($y);
    return array_pop($thestack);
  } else {
    return array();
  }
}

function execcode($f) {
  global $thestack;
  global $stackmark;
  global $thename;
  global $vars,$vars_stash,$vars_overload;
  global $thrown;
  global $extensions;
  global $stdinput;
  $catch=array();
  $m=0; $a=""; $f.="\n";
  for($i=0;$i<strlen($f);$i++) {
    $c=$f{$i};
    if($thrown) {
      $v3=null;
      if(isset($catch[$thrown[0]])) {
        $v3=$thrown[0];
      } else if(is_int($thrown[0])) {
        if($thrown[0]>0) {
          foreach($catch as $k=>$v) if(is_int($k)) if($k>0 && ($thrown[0]&$k)==$thrown[0]) $v3=$k;
        } else {
          foreach($catch as $k=>$v) if(is_int($k)) if($k<=0 && ((-$thrown[0])&-$k)==-$k) $v3=$k;
        }
      } else if(isset($catch[''])) {
        $v3='';
      }
      if($v3!==null) {
        array_push($thestack,$i,$thrown);
        $v=$catch[$v3];
        $v2=preg_match('/(^|\r|\n)\s*'.preg_quote($v,'/').'(\s)/',$f,$v1,PREG_OFFSET_CAPTURE);
        if($v2) $i=$v1[2][1]; else return 1;
        $thrown=false;
      } else return 1;
    }
    if($m>0) {
      if($c=='{') $m++;
      if($c=='}') $m--;
      if($m==0) $thestack[]=$a;
      else $a=$a.$c;
    } else {
      if(ctype_alpha($c) || ctype_digit($c) || $c=="_") {
        if($c=="_" && isset($vars_overload[$thename])) $thename=$vars_overload[$thename];
        $thename=$thename.$c;
        if(!ctype_upper($c) && ctype_upper($thename[0]) && $thename!="") {$c=$thename;$thename="";}
      } else if($c==":") {
        if($thename=="") $thename="_";
        if(isset($vars_overload[$thename])) $thename=$vars_overload[$thename];
        if(is_array($thename)) {
          $v1=&$vars[$thename[0]];
          foreach($thename as $k=>$v) if($k) $v1=&$v1[$v];
          $v2=array_pop($thestack);
          foreach($v2 as $v) $v1=&$v1[$v];
          $v1=array_pop($thestack);
          unset($v1);
        } else {
          $vars[$thename]=array_pop($thestack);
        }
        $thename="";
      } else if($c==";" && $thename!="") {
        $c="";
        if(isset($extensions[$thename])) call_user_func($extensions[$thename],&$c,&$f,&$i);
        $thename="";
      } else if($c=="'" && $thename!="") {
        if(isset($vars_overload[$thename])) $thename=$vars_overload[$thename];
        if(is_array($thename)) $thename=implode(' ',$thename).' ';
        $thestack[]=$thename;
        $thename="";
        $c="";
      } else if($thename!="" && (ctype_lower($thename[0]) || ctype_digit($thename[0]) || $thename[0]=="_")) {
        if(isset($vars_overload[$thename])) $thename=$vars_overload[$thename];
        if(is_array($thename)) {
          $v1=&$vars[$thename[0]];
          foreach($thename as $k=>$v) if($k) $v1=&$v1[$v];
          $v2=array_pop($thestack);
          foreach($v2 as $v) $v1=&$v1[$v];
          $thestack[]=$v1;
          unset($v1);
        } else if(ctype_digit($thename)) {
          $thestack[]=0+$thename;
        } else if(substr($thename,0,2)=='0x' && ctype_xdigit(substr($thename,2))) {
          $thestack[]=hexdec(substr($thename,2));
        } else if($thename[0]=="_" && ctype_digit(substr($thename,1)) && $thename!="_") {
          $thestack[]=0-substr($thename,1);
        } else if(isset($vars[$thename])) {
          $thestack[]=$vars[$thename];
        }
        $thename="";
      } else if($thename!="") {
        $c=$thename.$c;
        if(!ctype_upper($c)) $thename="";
      }
      if($c=='{') { //string
        $a="";
        $m=1;
      }
      $v=$thestack[count($thestack)-1];
      //if(is_int($v) && isset($extensions['__number'])) call_user_func($extensions['__number'],&$c,&$f,&$i);
      //if(is_object($v)) $v->next_command(&$c,&$f,&$i);
      if($c=='~') { //not/eval/dump/--in-out-listnum
        $v=array_pop($thestack);
        if(is_int($v)) {
          $thestack[]=~$v;
        } else if(is_string($v)) {
          execcode($v);
        } else if(is_array($v)) {
          $thestack=array_merge($thestack,$v);
        } else if(is_object($v)) {
          $v->cmd_eval();
        } else if(is_null($v)) {
          $v='';
          while(!feof($stdinput)) $v.=fread($stdinput,8192);
          mark_stack();
          execcode($v);
          if(!isset($vars['y'])) $vars['y']=$thestack[0];
          end_mark_stack();
          $f.="\nPa";
        }
      }
      if($c=='}') { //right-brace
        $v=array_pop($thestack);
        if(is_string($v)) {
          $thestack[]=str_split($v);
        } else if(is_int($v)) {
          $thestack[]=(int)abs($v);
          if($v>0) $thestack[]=range($v,1);
          else $thestack[]=array();
        } else if(is_array($v)) {
          $thestack[]=$v;
          $vars['_']=$v;
        }
      }
      if($c=='`') { //reverse-eval
        $v=array_pop($thestack);
        if(is_int($v)) {
          if($v>=0) $thestack[]=''.$v; else $thestack[]='_'.-$v;
        } else if(is_string($v)) {
          $thestack[]='{'.$v.'}';
        }
      }
      if($c=='!') { //logical-not
        $v=array_pop($thestack);
        if($v===0 || $v==="" || $v===array()) $thestack[]=1;
        else $thestack[]=0;
      }
      if($c=='@') { //rotate
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        array_push($thestack,$v2,$v1,$v3);
      }
      if($c=='$') { //copy/sort
        $v=array_pop($thestack);
        if(is_int($v)) {
          $thestack[]=$thestack[count($thestack)-1-$v];
        } else if(is_string($v)) {
          $v=str_split($v);
          sort($v);
          $thestack[]=implode('',$v);
        } else if(is_array($v)) {
          sort($v);
          $thestack[]=$v;
        }
      }
      if($c=='+') { //add/concatenate
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_array($v2) && !is_array($v1)) {
          $thestack[]=array_merge($v2,array($v1));
        } else if(is_int($v1)) {
          $thestack[]=$v2+$v1;
        } else if(is_string($v1)) {
          $thestack[]=$v2.$v1;
        } else if(is_array($v1)) {
          $thestack[]=array_merge((array)$v2,$v1);
        }
      }
      if($c=='-') { //subtract/set-subtract
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_array($v1) || is_array($v2)) {
          $thestack[]=array_values(array_diff($v2,(array)$v1));
        } else if(is_int($v1)) {
          $thestack[]=$v2-$v1;
        } else if(is_string($v1)) {
          $thestack[]=str_replace($v1,'',$v2);
        }
      }
      if($c=='*') { //multiply/repeat/join/fold
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=$v2*$v1;
        } else if(is_int($v1) && is_string($v2)) {
          $thestack[]=str_repeat($v2,$v1);
        } else if(is_int($v1) && is_array($v2)) {
          $thestack[]=array_repeat($v2,$v1);
        } else if(is_string($v1) && is_string($v2)) {
          $thestack[]=implode($v1,str_split($v2));
        } else if(is_array($v1) && is_array($v2)) {
          $thestack[]=array_implode($v1,$v2);
        } else if(is_string($v1) && is_array($v2)) {
          $thestack[]=array_shift($v2);
          foreach($v2 as $v) {
            $thestack[]=$v;
            execcode($v1);
          }
        }
      }
      if($c=='/') { //divide/explode/chunk/each
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=(int)($v2/$v1);
        } else if(is_int($v1) && is_string($v2)) {
          $thestack[]=str_split($v2,$v1);
        } else if(is_int($v1) && is_array($v2)) {
          $thestack[]=array_chunk($v2,$v1);
        } else if(is_string($v1) && is_string($v2)) {
          $thestack[]=explode($v1,$v2);
        } else if(is_array($v1) && is_array($v2)) {
          // It's supposed to do something?
        } else if(is_string($v1) && is_array($v2)) {
          foreach($v2 as $v) {
            $thestack[]=$v;
            execcode($v1);
          }
        }
      }
      if($c=='%') { //modulo/skip-elements/while
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          while($v2<0) $v2+=$v1;
          $thestack[]=$v2%$v1;
        } else if(is_int($v1) && is_array($v2)) {
          $out=array();
          if($v1) for($v=($v1>0?0:count($v2)-1);isset($v2[$v]);$v+=$v1) $out[]=$v2[$v];
          $thestack[]=$out;
        } else if(is_string($v1) && is_string($v2)) {
          execcode($v2);
          while(array_pop($thestack)) execcode($v1."\n".$v2);
        } else if(is_string($v1) && is_array($v2)) {
          mark_stack();
          foreach($v2 as $v) {
            $thestack[]=$v;
            execcode($v1);
          }
          end_mark_stack();
        }
      }
      if($c=='|') { //or/set-or
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=$v2|$v1;
        } else if(is_array($v1) && is_array($v2)) {
          $thestack[]=array_values(array_unique(array_merge($v2,$v1)));
        } else if(is_string($v1)) {
          if($v2) $thestack[]=$v2; else execcode($v1);
        }
      }
      if($c=='&') { //and/set-and
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=$v2&$v1;
        } else if(is_array($v1) && is_array($v2)) {
          $thestack[]=array_values(array_intersect($v2,$v1));
        } else if(is_string($v1)) {
          if($v2) execcode($v1); else $thestack[]=$v2;
        }
      }
      if($c=='^') { //xor/set-xor/filter
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=$v2^$v1;
        } else if(is_array($v1) && is_array($v2)) {
          $thestack[]=array_merge(array_diff($v2,$v1),array_diff($v1,$v2));
        } else if(is_string($v1) && is_array($v2)) {
          $out=array();
          foreach($v2 as $v) {
            $thestack[]=$v;
            execcode($v1);
            if(array_pop($thestack)) $out[]=$v;
          }
          $thestack[]=$out;
        }
      }
      if($c=='[') { //mark
        mark_stack();
      }
      if($c==']') { //end-mark/quick-echo-string
        if(count($stackmark)) {
          end_mark_stack();
        } else {
          $v=array_pop($thestack);
          if(is_array($v)) $v=implode('',$v);
          echo $v;
        }
      }
      if($c=='\\') { //swap
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        array_push($thestack,$v1,$v2);
      }
      if($c==';') { //discard
        array_pop($thestack);
      }
      if($c=='<') { //less
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if((is_int($v1) && is_int($v2)) || (is_string($v1) && is_string($v2))) {
          $thestack[]=(int)($v2<$v1);
        } else if(is_int($v1) && is_array($v2)) {
          $thestack[]=array_splice($v2,0,$v1);
        }
      }
      if($c=='>') { //greater
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if((is_int($v1) && is_int($v2)) || (is_string($v1) && is_string($v2))) {
          $thestack[]=(int)($v2>$v1);
        } else if(is_int($v1) && is_array($v2)) {
          $thestack[]=array_splice($v2,$v1);
        }
      }
      if($c=='=') { //equal/array-element
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if((is_int($v1) && is_int($v2)) || (is_string($v1) && is_string($v2))) {
          $thestack[]=(int)($v2==$v1);
        } else if(is_int($v1) && is_array($v2)) {
          if($v1<0) $v1=count($v2)+$v1;
          $thestack[]=$v2[$v1];
        }
      }
      if($c==',') { //range/count
        $v1=array_pop($thestack);
        if(is_int($v1)) {
          if($v1>0) $thestack[]=range(0,$v1-1);
          if($v1==0) $thestack[]=array();
          if($v1<0) $thestack[]=range(-1,$v1);
        } else if(is_array($v1)) {
          $thestack[]=count($v1);
        } else if(is_string($v1)) {
          $thestack[]=strlen($v1);
        }
      }
      if($c=='.') { //duplicate
        $v=array_pop($thestack);
        array_push($thestack,$v,$v);
      }
      if($c=='?') { //power/find/if
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_int($v1) && is_int($v2)) {
          $thestack[]=(int)pow($v2,$v1);
        } else if(is_array($v1)) {
          $v=array_search($v2,$v1);
          if(is_int($v)) $thestack[]=$v; else $thestack[]=-1;
        } else if(is_string($v1) && is_array($v2)) {
          $out=-1;
          foreach($v2 as $k=>$v) {
            $thestack[]=$v;
            execcode($v1);
            if(array_pop($thestack)) {$out=$k;break;}
          }
          $thestack[]=$out;
        } else if(is_string($v1) && is_int($v2)) {
          if($v2) execcode($v1);
        } else if(is_string($v1) && is_string($v2)) {
          $v=strpos($v2,$v1);
          if($v===false) $v=-1;
          $thestack[]=$v;
        }
      }
      if($c=='(') { //decrement/uncons-first
        $v=array_pop($thestack);
        if(is_int($v)) {
          $thestack[]=$v-1;
        } else if(is_array($v)) {
          $v2=array_shift($v);
          array_push($thestack,$v,$v2);
        } else if(is_string($v)) {
          $v=str_split($v,1);
          $v2=array_shift($v);
          array_push($thestack,implode("",$v),$v2);
        }
      }
      if($c==')') { //increment/uncons-last/--in-out-line-array
        $v=array_pop($thestack);
        if(is_int($v)) {
          $thestack[]=$v+1;
        } else if(is_array($v)) {
          $v2=array_pop($v);
          array_push($thestack,$v,$v2);
        } else if(is_string($v)) {
          $v=str_split($v,1);
          $v2=array_pop($v);
          array_push($thestack,implode("",$v),$v2);
        } else if(is_null($v)) {
          $f='Ia10"/'.substr($f,$i+1).' A_P.';
          $i=-1;
        }
      }
      if($c=='"') { //chr/ord-list/reverse-array/--in-out-per-line
        $v=array_pop($thestack);
        if(is_int($v)) {
          $thestack[]=chr($v);
        } else if(is_string($v)) {
          $out=array();
          for($v1=0;$v1<strlen($v);$v1++) $out[]=ord($v[$v1]);
          $thestack[]=$out;
        } else if(is_array($v)) {
          $thestack[]=array_reverse($v);
        } else if(is_null($v)) {
          $f='{0 I1\;'.substr($f,$i+1).' P,1}Fd';
          $i=-1;
        }
      }
      if($c=='#') { //replace-execution/adjust-stack-mark/almost-execute/--in-out
        $v=array_pop($thestack);
        if(is_string($v)) {
          $f=$v.substr($f,$i+1);
          $i=-1;
        } else if(is_int($v)) {
          $v1=array_pop($stackmark);
          $stackmark[]=$v1-$v;
        } else if(is_array($v)) {
          foreach($v as $v1=>$v2) {
            $v[$v1]=almost_execute($v2);
          }
          $thestack[]=$v;
        } else if(is_null($v)) {
          $f=' Ia '.substr($f,$i+1).' P. ';
          $i=-1;
        }
      }
      if($c=='A+') { //array-sum
        $v=array_pop($thestack);
        if(is_string($v)) {
          $v2=array_pop($thestack);
          mark_stack();
          foreach($v2 as $v1) {
            $thestack[]=$v;
            execcode($v);
          }
          end_mark_stack();
        }
        $thestack[]=array_sum($v);
      }
      if($c=='A.') { //array-implode
        $v=array_pop($thestack);
        $thestack[]=implode('',$v);
      }
      if($c=='A,') { //array-implode-delimiter
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=implode($v1,$v2);
      }
      if($c=='A_') { //array-implode-newline
        $v=array_pop($thestack);
        if(is_array($v)) $thestack[]=implode("\n",$v);
        else $thestack[]=''.$v;
      }
      if($c=='A#') { //array-implode-space
        $v=array_pop($thestack);
        if(is_array($v)) $thestack[]=implode(" ",$v);
        else $thestack[]=''.$v;
      }
      if($c=='A*') { //array-product
        $v=array_pop($thestack);
        if(is_string($v)) {
          $v2=array_pop($thestack);
          mark_stack();
          foreach($v2 as $v1) {
            $thestack[]=$v;
            execcode($v);
          }
          end_mark_stack();
        }
        $out=1;
        foreach($v as $v1) $out*=$v1;
        $thestack[]=$out;
      }
      if($c=='Az') { //array-zip
        $v=array_pop($thestack);
        if(!count($v)) {
          $thestack[]=array();
        } else if(is_array($v[0])) {
          $thestack[]=array_zip($v);
        } else if(is_string($v[0])) {
          $v=array_map(str_split,$v);
          $thestack[]=array_map(implode,array(),array_zip($v));
        } else if(is_int($v[0])) {
          $v2=array_fill(0,32,(int)0);
          for($v1=0;$v1<count($v);$v1++) {
            for($v3=0;$v3<32;$v3++) {
              $v2[$v3]|=(($v[$v1]>>$v3)&1)<<$v1;
            }
          }
          $thestack[]=$v2;
        }
      }
      //if($c=='As') { //array-shuffle/string-shuffle
      //  $v=array_pop($thestack);
      //  if(is_array($v)) {
      //    shuffle($v);
      //    $thestack[]=$v;
      //  } else if(is_string($v)) {
      //    $v=str_split($v,1);
      //    shuffle($v);
      //    $thestack[]=implode("",$v);
      //  }
      //}
      if($c=='Ar') { //array-reverse/string-reverse
        $v=array_pop($thestack);
        if(is_array($v)) $thestack[]=array_reverse($v);
        if(is_string($v)) $thestack[]=strrev($v);
        if(is_int($v)) $thestack[]=(int)(0+strrev(''.$v));
      }
      if($c=='A$') { //array-multisort
        $v=array_pop($thestack);
        call_user_func_array(array_multisort,&$v);
        $thestack[]=$v;
      }
      if($c=='A=') { //array-set-element
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        if(is_array($v2) && is_int($v1)) {
          if($v1>=0 && $v1<=count($v2)) $v2[$v1]=$v3;
          $thestack[]=$v2;
        }
      }
      if($c=='Af') { //array-flatten
        $v=array_pop($thestack);
        foreach($v as $v1=>$v2) $v[$v1]=(array)$v2;
        $thestack[]=call_user_func_array(array_merge,$v);
      }
      if($c=='A\\') { //array-diagonal-bs
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $out=array();
        foreach($v2 as $k=>$v) if(isset($v[$v1+$k])) $out[]=$v[$v1+$k];
        $thestack[]=$out;
      }
      if($c=='A/') { //array-diagonal-fs
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $out=array();
        foreach($v2 as $k=>$v) if(isset($v[$v1-$k])) $out[]=$v[$v1-$k];
        $thestack[]=$out;
      }
      if($c=='At') { //array-tuples
        $v=array_pop($thestack);
        if(count($v) && !is_array($v[0])) $v=array(array_pop($thestack),$v);
        $thestack[]=array_tuples($v);
      }
      if($c=='Ax') { //array-cross
        $v1=(array)array_pop($thestack); $v2=(array)array_pop($thestack);
        $v3=array_pop($thestack);
        mark_stack();
        foreach(array_tuples(array($v1,$v2)) as $v) {
          $thestack[]=$v;
          execcode($v3);
        }
        end_mark_stack();
      }
      if($c=='Ag') { //array-get-consecutive
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $out=array();
        for($k=0;$k<=count($v2)-$v1;$k++) $out[]=array_slice($v2,$k,$v1);
        $thestack[]=$out;
      }
      if($c=='A-') { //array-remove-element
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        while($v1<0) $v1+=count($v2);
        $v1=$v1%count($v2);
        $v1=array_splice($v2,$v1,1);
        $thestack[]=$v2;
        $thestack[]=$v1;
      }
      if($c=='Au') { //array-u-turn
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        while($v1<0) $v1+=count($v2);
        $thestack[]=array_merge(array_slice($v2,$v1),array_slice($v2,0,$v1));
      }
      if($c=='A?') { //array-test-unique
        $v=array_pop($thestack);
        if(count($v)==count(array_unique($v))) $thestack[]=1;
        else $thestack[]=0;
      }
      if($c=='AP[') { //array-pad-left
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        $thestack[]=array_slice(array_merge(array_fill(0,$v2,$v1),$v3),-$v2);
      }
      if($c=='AP]') { //array-pad-right
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        $thestack[]=array_slice(array_merge($v3,array_fill(0,$v2,$v1)),0,$v2);
      }
      if($c=='AZt') { //array-tuples-callback
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=array_tuples_callback($v2,$v1);
      }
      if($c=='B+') { //bcmath-add
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcadd($v2,$v1);
      }
      if($c=='B-') { //bcmath-subtract
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcsub($v2,$v1);
      }
      if($c=='B*') { //bcmath-multiply
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcmul($v2,$v1);
      }
      if($c=='B/') { //bcmath-divide
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcdiv($v2,$v1);
      }
      if($c=='B%') { //bcmath-modulo
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcmod($v2,$v1);
      }
      if($c=='B?') { //bcmath-power
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bcpow($v2,$v1);
      }
      if($c=='B=') { //bcmath-compare
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=bccomp($v2,$v1);
      }
      if($c=='Bs') { //bcmath-scale
        $v=array_pop($thestack);
        $thestack[]=bcscale($v);
      }
      if($c=='F<') { //flow-control-restart
        $i=-1;
      }
      if($c=='F>') { //flow-control-exit
        return 0;
      }
      if($c=='F[') { //flow-control-conditional-restart
        if(array_pop($thestack)) $i=-1;
      }
      if($c=='F]') { //flow-control-conditional-exit
        if(array_pop($thestack)) return 0;
      }
      if($c=='Fd') { //flow-control-do
        $v=array_pop($thestack);
        do{execcode($v);} while(array_pop($thestack));
      }
      if($c=='Fi') { //flow-control-if-else
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        if($v3) execcode($v2); else execcode($v1);
      }
      if($c=='F%') { //flow-control-recursive-map
        $v=array_pop($thestack);
        if(is_array($v)) {
          mark_stack();
          foreach($v as $v1) {
            $thestack[]=$v1;
            execcode($f);
          }
          end_mark_stack();
          return 0;
        } else {
          $thestack[]=$v;
        }
      }
      if($c=='F/') { //flow-control-recursive-each
        $v=array_pop($thestack);
        if(is_array($v)) {
          foreach($v as $v1) {
            $thestack[]=$v1;
            execcode($f);
          }
          return 0;
        } else {
          $thestack[]=$v;
        }
      }
      if($c=='F.') { //flow-control-goto
        $v=array_pop($thestack);
        $v2=preg_match('/(^|\r|\n)\s*'.preg_quote($v,'/').'(\s)/',$f,$v1,PREG_OFFSET_CAPTURE);
        if($v2) $i=$v1[2][1];
      }
      if($c=='F?') { //flow-control-conditional-goto
        $v=array_pop($thestack); $v2=array_pop($thestack);
        $v2=$v2&&preg_match('/(^|\r|\n)\s*'.preg_quote($v,'/').'(\s)/',$f,$v1,PREG_OFFSET_CAPTURE);
        if($v2) $i=$v1[2][1];
      }
      if($c=='Fg') { //flow-control-gosub
        $v=array_pop($thestack);
        $v2=preg_match('/(^|\r|\n)\s*'.preg_quote($v,'/').'(\s)/',$f,$v1,PREG_OFFSET_CAPTURE);
        if($v2) {
          $thestack[]=$i;
          $i=$v1[2][1];
        }
      }
      if($c=='Fc') { //flow-control-conditional-gosub
        $v=array_pop($thestack); $v2=array_pop($thestack);
        $v2=$v2&&preg_match('/(^|\r|\n)\s*'.preg_quote($v,'/').'(\s)/',$f,$v1,PREG_OFFSET_CAPTURE);
        if($v2) {
          $thestack[]=$i;
          $i=$v1[2][1];
        }
      }
      if($c=='Fr') { //flow-control-return
        $i=array_pop($thestack);
      }
      if($c=='F~') { //flow-control-alt-exec
        $v=array_pop($thestack);
        if(execcode($v)) return 1;
      }
      if($c=='F1') { //flow-control-reconsider
        return 1;
      }
      if($c=='F2') { //flow-control-conditional-reconsider
        if(array_pop($thestack)) return 1;
      }
      if($c=='Fm') { //flow-control-maybe
        $v=array_pop($thestack)."\n".substr($f,$i+1);
        if(!maybe_execute($v)) return 0;
      }
      if($c=='Fw') { //flow-control-maybe-not
        $v=array_pop($thestack);
        if(!maybe_execute(substr($f,$i+1))) return 0;
        execcode($v);
      }
      if($c=='Fy') { //flow-control-yield
        $v=array_pop($thestack);
        $thestack[]=array($i,$f);
        if(is_string($v)) $v=array(-1,$v);
        $i=$v[0];
        $f=$v[1];
      }
      if($c=='Ft') { //flow-control-throw
        $thrown=array_pop($thestack);
        if(is_object($thrown[0])) $thrown[0]=$thrown[0]->convert();
      }
      if($c=='F(') { //flow-control-catch
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_object($v2)) $v2=$v2->convert();
        $catch[$v2]=$v1;
      }
      if($c=='F)') { //flow-control-fumble
        $v2=array_pop($thestack);
        if(is_object($v2)) $v2=$v2->convert();
        unset($catch[$v2]);
      }
      if($c=='Fp') { //flow-control-fixed-point
        $v1=array_pop($thestack); execcode($v1);
        $v2=array_pop($thestack);
        do {
          $v=$v2; $thestack[]=$v;
          execcode($v1); $v2=array_pop($thestack);
        } while($v!=$v2);
        $thestack[]=$v;
      }
      if($c=='Fo') { //flow-control-forever
        $f=substr($f,$i+1)."\nF<";
        $i=-1;
      }
      if($c=='F|') { //flow-control-conditional-drop-exit
        if(!array_pop($thestack)) {
          array_pop($thestack);
          return 0;
        }
      }
      if($c=='F9') { //flow-control-alt-point
        $v1=array_pop($thestack); execcode($v1);
        $v2=array_pop($thestack); $v=array();
        do {
          $v[]=$v2; $thestack[]=$v2;
          execcode($v1); $v2=array_pop($thestack);
        } while(array_search($v2,$v,true)===false);
        $thestack[]=$v2;
      }
      if($c=='Ia') { //input-all
        //$v=file_get_contents("php://stdin");
        $v='';
        while(!feof($stdinput)) $v.=fread($stdinput,8192);
        $thestack[]=str_replace("\r","",$v);
      }
      if($c=='Il') { //input-line
        $v=fgets($stdinput);
        while($v[strlen($v)-1]=="\r" || $v[strlen($v)-1]=="\n") $v=substr($v,0,-1);
        $thestack[]=$v;
      }
      if($c=='I1') { //input-line-or-eof
        $v=fgets($stdinput);
        if(feof($stdinput)) return 0;
        while($v[strlen($v)-1]=="\r" || $v[strlen($v)-1]=="\n") $v=substr($v,0,-1);
        $thestack[]=$v;
      }
      if($c=='I0') { //input-until
        $v1=array_pop($thestack);
        $o=""; $v3=0;
        while(($v=fgetc($stdinput))!==false) {
          if($v==$v1[0] && $v3==0) break;
          if(strlen($v1)>2) {
            if($v==$v1[1]) $v3++;
            if($v==$v1[2]) $v3--;
          }
          $o.=$v;
        }
        $thestack[]=$o;
      }
      if($c=='M2') { //math-dec-to-bin
        $v=array_pop($thestack);
        $thestack[]=decbin($v);
      }
      //if($c=='Mr') { //math-random
      //  $v=array_pop($thestack);
      //  $thestack[]=mt_rand(0,$v-1);
      //}
      if($c=='Ma') { //math-absolute
        $v=array_pop($thestack);
        $thestack[]=abs($v);
      }
      if($c=='Ms') { //math-sign
        $v=array_pop($thestack);
        $thestack[]=($v?($v>0?1:-1):0);
      }
      if($c=='M$') { //math-interleave
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $v1=($v1|($v1<<8))&0x00FF00FF;
        $v1=($v1|($v1<<4))&0x0F0F0F0F;
        $v1=($v1|($v1<<2))&0x33333333;
        $v1=($v1|($v1<<1))&0x55555555;
        $v2=($v2|($v2<<8))&0x00FF00FF;
        $v2=($v2|($v2<<4))&0x0F0F0F0F;
        $v2=($v2|($v2<<2))&0x33333333;
        $v2=($v2|($v2<<1))&0x55555555;
        $thestack[]=$v1|($v2<<1);
      }
      if($c=='Mb') { //math-base-convert
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        $thestack[]=base_convert((string)$v1,$v2,$v3);
      }
      if($c=='Md') { //math-decimal
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=(int)base_convert($v2,$v1,10);
      }
      if($c=='P.') { //print-value
        $v=array_pop($thestack);
        if(is_array($v)) echo $v[0];
        else echo $v;
      }
      if($c=='P,') { //print-value-newline
        echo array_pop($thestack)."\n";
      }
      if($c=='P_') { //print-newline
        echo "\n";
      }
      if($c=='Pr') { //print-r
        print_r(array_pop($thestack));
      }
      if($c=='Ps') { //print-stack
        var_dump($thestack);
      }
      if($c=='Pc') { //print-character
        $v=array_pop($thestack);
        if(is_int($v)) echo chr($v);
        if(is_string($v)) echo $v[0];
        if(is_array($v)) foreach($v as $v1) echo chr($v1);
      }
      if($c=='Pf') { //print-format
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        call_user_func_array(printf,array_merge((array)$v1,(array)$v2));
      }
      if($c=='Pa') { //print-all-list
        $v=array_pop($thestack);
        if(is_array($v)) echo implode("\n",$v);
        else echo $v;
      }
      if($c=='Sc') { //string-contains
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=(strcspn($v2,$v1)==strlen($v2)?0:1);
      }
      if($c=='Sn') { //string-append-newline
        $v=array_pop($thestack);
        $thestack[]=$v."\n";
      }
      if($c=='St') { //string-translate
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        $thestack[]=strtr($v3,$v2,$v1);
      }
      if($c=='Sl') { //string-lowercase
        $v=array_pop($thestack);
        $thestack[]=strtolower($v);
      }
      if($c=='Su') { //string-uppercase
        $v=array_pop($thestack);
        $thestack[]=strtoupper($v);
      }
      if($c=='Sf') { //string-format
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=call_user_func_array(sprintf,array_merge((array)$v1,(array)$v2));
      }
      if($c=='Sb') { //string-brainfuck
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack=array_merge($thestack,brainfuck($v1,$v2));
      }
      if($c=='Sx') { //string-expand
        $v=array_pop($thestack);
        $thestack[]=str_expand_special($v);
      }
      if($c=='S|') { //string-trim
        $v=array_pop($thestack);
        if(is_array($v)) $v=implode("\n",$v);
        $thestack[]=trim($v);
      }
      if($c=='S[') { //string-ltrim
        $v=array_pop($thestack);
        if(is_array($v)) $v=implode("\n",$v);
        $thestack[]=ltrim($v);
      }
      if($c=='S]') { //string-rtrim
        $v=array_pop($thestack);
        if(is_array($v)) $v=implode("\n",$v);
        $thestack[]=rtrim($v);
      }
      if($c=='S(') { //string-cspn
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=strcspn($v2,$v1);
      }
      if($c=='S)') { //string-spn
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $thestack[]=strspn($v2,$v1);
      }
      if($c=='S0') { //string-upto-first
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(strlen($v1)==1) {
          $v=strpos($v2,$v1);
          if($v===false) array_push($thestack,"",$v2);
          else array_push($thestack,substr($v2,$v+1),substr($v2,0,$v));
        } else if(strlen($v1)==3) {
          $v3=0;
          for($k=0;$k<strlen($v2);$k++) {
            if($v3==0 && $v2[$k]==$v1[0]) break;
            if($v2[$k]==$v1[1]) $v3++;
            if($v2[$k]==$v1[2]) $v3--;
          }
          array_push($thestack,substr($v2,$k+1),substr($v2,0,$k));
        }
      }
      if($c=='S5') { //string-remove-disallowed
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        if(is_array($v2)) $v2=implode("\n",$v2);
        $thestack[]=preg_replace('|[^'.preg_quote($v1,'-').']|',"",$v2);
      }
      if($c=='S!') { //string-regex-match-offset
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        preg_match_all($v1,$v2,$out,PREG_OFFSET_CAPTURE);
        $v=array();
        foreach($out[0] as $v3) $v[]=$v3[1];
        $thestack[]=$v;
      }
      if($c=='S?') { //string-regex-match
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        preg_match_all($v1,$v2,$out,PREG_SET_ORDER);
        $thestack[]=$out;
      }
      if($c=='S"') { //string-regex-quote
        $v=array_pop($thestack);
        $thestack[]=preg_quote($v,'/');
      }
      if($c=='S~') { //string-regex-replace-call
        $v1=array_pop($thestack); $v2=array_pop($thestack); $v3=array_pop($thestack);
        $v4=substr($v2,strrpos($v2,$v2[0])+1);
        $v2=substr($v2,0,strrpos($v2,$v2[0])+1).strtr($v4,"[1-","   ");
        if(strpos($v4,"-")!==false) $v1="0= ".$v1;
        if(strpos($v4,"[")!==false) {
          mark_stack();
          $v1.=" {}";
        }
        if(strpos($v4,"1")!==false) {
          $thestack[]=preg_replace_callback($v2,array(new flogback($v1),'call'),$v3,1);
        } else {
          $thestack[]=preg_replace_callback($v2,array(new flogback($v1),'call'),$v3);
        }
        if(strpos($v4,"[")!==false) {
          array_pop($thestack);
          end_mark_stack();
        }
      }
      if($c=='S`') { //string-heredoc
        $f=substr($f,$i+1);
        $i=-1;
        $v1=substr($f,0,strpos($f,"\n"));
        $f=substr($f,strpos($f,"\n")+1);
        $v2=strpos($f,"\n".$v1."\n");
        $thestack[]=substr($f,0,$v2);
        $f=substr($f,$v2+2+strlen($v1));
      }
      if($c=='V<') { //variable-stash
        $v=array_pop($thestack);
        if(is_string($v)) $v=explode("|",$v);
        foreach($v as $v1) $vars_stash[$v1][]=$vars[$v1];
      }
      if($c=='V>') { //variable-retrieve
        $v=array_pop($thestack);
        if(is_string($v)) $v=explode("|",$v);
        foreach($v as $v1) $vars[$v1]=array_pop($vars_stash[$v1]);
      }
      if($c=='V!') { //variable-overload
        $v1=array_pop($thestack); $v2=array_pop($thestack);
        $vars_overload[$v2]=$v1;
      }
      if($c=='V=') { //variable-not-overload
        $v=array_pop($thestack);
        unset($vars_overload[$v]);
      }
      if($c=='V?') { //variable-which-overload
        $v=array_pop($thestack);
        if(isset($vars_overload[$v])) $thestack[]=$vars_overload[$v];
        else $thestack[]=$v;
      }
      if($c=='Vx') { //variable-delete
        $v=array_pop($thestack);
        if(is_string($v)) $v=explode("|",$v);
        foreach($v as $v1) {
          unset($vars[$v1]);
          unset($vars_stash[$v1]);
          unset($vars_overload[$v1]);
        }
      }
      if($c=='Vl') { //variable-local
        $v=array_pop($thestack);
        if(is_string($v)) $v=explode("|",$v);
        foreach($v as $v1) $vars_stash[$v1][]=$vars[$v1];
        $out=execcode(substr($f,$i+1));
        foreach($v as $v1) $vars[$v1]=array_pop($vars_stash[$v1]);
        return $out;
      }
      if($c=='V(') { //variable-select-prev
        $v=array_pop($thestack);
        $vars_overload[$v][count($vars_overload[$v])-1]--;
      }
      if($c=='V)') { //variable-select-next
        $v=array_pop($thestack);
        $vars_overload[$v][count($vars_overload[$v])-1]++;
      }
      if($c=='Vi') { //variable-select-inner
        $v=array_pop($thestack);
        $vars_overload[$v][]=0;
      }
      if($c=='Vo') { //variable-select-outer
        $v=array_pop($thestack);
        array_pop($vars_overload[$v]);
      }
      if($c=='X+') { //matrix-add
        $v2=array_pop($thestack); $v1=array_pop($thestack);
        $thestack[]=matrix_add($v1,$v2);
      }
      if($c=='Z^') { //misc-inline-filter
        $v=array_pop($thestack);
        if($v===0 || $v==="" || $v===array()) array_pop($thestack);
      }
      if($c=='Z2') { //misc-2dup
        $v2=array_pop($thestack); $v1=array_pop($thestack);
        array_push($thestack,$v1,$v2,$v1,$v2);
      }
      if($c=='Z3') { //misc-3dup
        $v3=array_pop($thestack); $v2=array_pop($thestack); $v1=array_pop($thestack);
        array_push($thestack,$v1,$v2,$v3,$v1,$v2,$v3);
      }
      if($c=='Zo') { //misc-over
        $v2=array_pop($thestack); $v1=array_pop($thestack);
        array_push($thestack,$v1,$v2,$v1);
      }
    }
  }
  if($m) {
    if(is_array($thestack[count($thestack)-1])) {
      $v2=array_pop($thestack);
      mark_stack();
      foreach($v2 as $v) {
        $thestack[]=$v;
        execcode($a);
      }
      end_mark_stack();
    } else {
      execcode($a);
    }
  }
}

$vars=array(
  'a'=>'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
  'aa'=>'abcdefghijklmnopqrstuvwxyz',
  'as'=>'*',
  'c'=>'}',
  'd'=>'.',
  'e'=>'',
  'f'=>'{}',
  'g'=>'{',
  'i'=>')',
  'j'=>'(',
  'n'=>"\n",
  'o'=>';_',
  'p'=>'.+',
  'pp'=>' _+',
  'q'=>"_\\:",
  'r'=>' Ar',
  's'=>' ',
  'sp'=>' 1/',
  'sq'=>' 0+.*',
  'th'=>1000,
  'z'=>array(0),
  'zz'=>array(0,0),
);

$extchars=array(
  '€'=>'[1#',
  '¡'=>' Ar ',
  '¢'=>' 1/ ',
  '«'=>' Ia ',
  '¬'=>' Az ',
  '°'=>' _# ',
  '²'=>'.*',
  '³'=>'..**',
  'µ'=>'}%',
  '¶'=>' P_ ',
  '¸'=>' ,i% ',
  '¹'=>' A= ',
  '»'=>' Pa ',
  'Æ'=>' A',
  'Ê'=>' F',
  'Ð'=>' S',
  'Ø'=>'[]',
  'Ù'=>'(\;',
  'Ú'=>')\;',
  'à'=>' a ',
  'è'=>' e ',
  'ì'=>' i ',
  'í'=>' j ',
  'ò'=>' o ',
  'ù'=>' u ',
);

$stdinput=STDIN;
$thestack=array();
$stackmark=array();
$thename="";
$vars_stash=array();
$vars_overload=array();
$thrown=false;
$extensions=array();
for($i=1;$i<count($argv);$i++) {
  switch($argv[$i]) {
    case '-c':
      $thestack=array();
      $thename="";
      $vars=array();
      break;
    case '-e':
      require $argv[++$i];
      break;
    case '-p':
      $thestack[]=$argv[++$i];
      break;
    case '-t':
      set_time_limit($argv[++$i]);
      break;
    case '-x':
      execcode(strtr(implode('',file($argv[++$i])),$extchars));
      break;
    default:
      execcode(str_replace("\r","",implode('',file($argv[$i]))));
      break;
  }
}
