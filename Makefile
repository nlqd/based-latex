TEX_FILES := main.tex $(wildcard src/*.tex)

# -n24: silence false positive for \label{} on its own line
CHKTEX_FLAGS := -q -l .chktexrc -n24

.PHONY: all watch clean realclean lint fmt fmt-check check

all:
	latexmk

watch:
	latexmk -pvc

clean:
	latexmk -c

realclean:
	latexmk -C

lint:
	@command -v chktex >/dev/null 2>&1 || { \
	  echo "chktex not installed; run: ./bin/t add chktex"; exit 1; }
	chktex $(CHKTEX_FLAGS) main.tex

fmt:
	@latexindent --version >/dev/null 2>&1 || { \
	  echo "latexindent not working; run: ./bin/t add latexindent"; \
	  echo "(also needs Perl modules; see README)"; exit 1; }
	@mkdir -p build
	latexindent -w -s -l -m --cruft=build/ --logfile=build/latexindent.log $(TEX_FILES)

fmt-check:
	@latexindent --version >/dev/null 2>&1 || { \
	  echo "latexindent not working (missing binary or Perl modules; see README)"; exit 1; }
	@for f in $(TEX_FILES); do \
	  latexindent -l -m --logfile=/dev/null $$f 2>/dev/null | diff -q $$f - >/dev/null \
	    || { echo "fmt-check: $$f is not formatted"; exit 1; }; \
	done

check: lint fmt-check
