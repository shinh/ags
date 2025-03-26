TARGETS := \
/golf/local/dmd2/bin/dmd \
/golf/local/dmd/linux/bin/dmd \
/usr/local/bin/goruby-1.9 \
/golf/local/j602 \
/usr/local/bin/xgawk \
/usr/local/bin/cyc \
/usr/local/bin/kite \
/golf/local/arc3/as2.scm \
/golf/local/gobin/8l \
/golf/local/fernando.py \
/golf/local/FlogScript.php \
/golf/local/wake/wake \
/golf/local/dosemu.tgz \
/golf/local/euphoria/bin/exu \
/golf/local/kona/k \
/golf/local/npiet-1.3a/npiet \
/golf/local/malbolge \
/golf/local/snobol4-1.4.1/snobol4 \
/golf/local/Burlesque/main_golf \
/golf/local/rust/bin/rustc \
/golf/local/chapel-1.7.0/bin/linux32/chpl \
/golf/local/SQUIRREL3/bin/sq \
/golf/local/ccbi-2.1/ccbi \
/golf/local/MNNBFSL/mnnbfsl \
/golf/local/gs2/gs2.py \
/golf/local/caheui/aheui \
/golf/local/fish \
/golf/local/crystal/bin/crystal \
/golf/local/hexagony/hexagony.rb \
/golf/local/labyrinth/interpreter.rb \
/golf/local/Brainfuck/tritium/bfi \
/usr/local/bin/ghc-8.0.2 \
/golf/local/jellylanguage/jelly/__main__.py \
/golf/local/nibbles/nibbles \
/golf/local/jq16 \
/golf/local/vyxal/vyxal/__main__.py
/golf/local/iogii

#/golf/local/dmd2/linux/bin/dmd \

all: $(TARGETS)
	make -C modules
	git archive HEAD srv | tar -C / -xvf -
	cd /golf && make
	chmod +s /golf/remount

#/golf/local/dmd2/linux/bin/dmd:
/golf/local/dmd2/bin/dmd:
	fetcher/d2

/golf/local/dmd/linux/bin/dmd:
	fetcher/d

/usr/local/bin/goruby-1.9:
	fetcher/grb

/golf/local/j602:
	fetcher/j

/usr/local/bin/xgawk:
	fetcher/xgawk

/usr/local/bin/cyc:
	fetcher/curry

/usr/local/bin/kite:
	fetcher/kt

/golf/local/arc3/as2.scm:
	fetcher/arc

/golf/local/gobin/8l:
	fetcher/go

/golf/local/fernando.py: fetcher/fernando.py
	cp $< $@
	chmod 755 $@

/golf/local/FlogScript.php: fetcher/FlogScript.php
	cp $< $@
	chmod 755 $@

/golf/local/wake/wake:
	fetcher/wake

/golf/local/dosemu.tgz: fetcher/dosemu.tgz
	cp $^ $@

/golf/local/euphoria/bin/exu:
	fetcher/exu

/golf/local/kona/k:
	fetcher/k

/golf/local/npiet-1.3a/npiet:
	fetcher/piet

/golf/local/malbolge:
	fetcher/mb

/golf/local/snobol4-1.4.1/snobol4:
	fetcher/sno

/golf/local/Burlesque/main_golf:
	fetcher/blsq

/golf/local/rust/bin/rustc:
	fetcher/rust

/golf/local/chapel-1.7.0/bin/linux32/chpl:
	fetcher/chpl

/golf/local/SQUIRREL3/bin/sq:
	fetcher/nut

/golf/local/ccbi-2.1/ccbi:
	fetcher/bef98

/golf/local/MNNBFSL/mnnbfsl:
	fetcher/bfsl

/golf/local/gs2/gs2.py:
	fetcher/gs2

/golf/local/caheui/aheui:
	fetcher/aheui

/golf/local/fish:
	fetcher/fsh

/golf/local/crystal/bin/crystal:
	fetcher/cr

/golf/local/hexagony/hexagony.rb:
	fetcher/hxg

/golf/local/labyrinth/interpreter.rb:
	fetcher/lab

/golf/local/Brainfuck/tritium/bfi:
	fetcher/bf8

/usr/local/bin/ghc-8.0.2:
	fetcher/hs

/golf/local/jellylanguage/jelly/__main__.py:
	fetcher/jelly

/golf/local/nibbles/nibbles:
	fetcher/nbb

/golf/local/jq16: fetcher/jq16
	cp $< $@

/golf/local/vyxal/vyxal/__main__.py:
	fetcher/vy
  
/usr/local/bin/ruby3.2: fetcher/rb3
	fetcher/rb3

/golf/local/atlas/atlas.rb: fetcher/atl /usr/local/bin/ruby3.2
	fetcher/atl

/golf/local/iogii: fetcher/iog
	fetcher/iog
