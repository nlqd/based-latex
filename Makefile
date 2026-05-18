.PHONY: all watch clean realclean

all:
	latexmk

watch:
	latexmk -pvc

clean:
	latexmk -c

realclean:
	latexmk -C
