TEX_FILES := main.tex $(wildcard src/*.tex)

# Warnings we silence project-wide:
#  -n24  "Delete this space to maintain correct pagereferences" — false positive
#        for our `\label{}` on its own line in section/figure/table contexts.
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
	@command -v latexindent >/dev/null 2>&1 || { \
	  echo "latexindent not installed; run: ./bin/t add latexindent"; \
	  echo "(also needs Perl modules; see README)"; exit 1; }
	@mkdir -p build
	latexindent -w -s -l -m --logfile=build/latexindent.log $(TEX_FILES)

fmt-check:
	@command -v latexindent >/dev/null 2>&1 || { \
	  echo "latexindent not installed"; exit 1; }
	@for f in $(TEX_FILES); do \
	  latexindent -s -l -m $$f | diff -q $$f - >/dev/null \
	    || { echo "fmt-check: $$f is not formatted"; exit 1; }; \
	done

check: lint fmt-check
