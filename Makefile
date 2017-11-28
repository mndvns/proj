NAME = proj
VERSION = 1.0.0

bin: src/ls bin/$(NAME)-ls

bin/$(NAME)-%: lib/%.sh
	ln -sf $(shell realpath $<) $@

src:
	mkdir $@ 2>/dev/null

src/%.c: lib/%.ggo src Makefile
	gengetopt < $< \
		--set-version=$(VERSION) \
	  --set-package=$(NAME)-$(basename $(@F)) \
		--file-name=$(basename $(@F)) \
		--output-dir=$(dir $@) \
		--no-version \
		--conf-parser \
		--string-parser \
		--include-getopt \
		--default-optional

src/%.o: src/%.c
	gcc -o $@ -c $<

src/%: src/%.o lib/%.cc
	g++ -o $@ $^

lib/%.sh: src/%

clean:
	rm -rf src
	rm -f bin/$(NAME)-*

.PHONY: test clean
