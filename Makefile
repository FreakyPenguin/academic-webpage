PAGES= index blog projects publications bio group

BLOGS= $(basename $(wildcard blogs/*.xml))
BLOG_PAGES= $(addsuffix .html,$(BLOGS))
ALL_PAGES= $(addprefix build/out/,$(addsuffix .html,$(PAGES)) $(BLOG_PAGES) \
	atom.xml)

TEMPLATE= build/singleplage.xml
SASS= sassc -t compressed

all: $(ALL_PAGES)

clean:
	rm -rf build

deploy-prepare: $(ALL_PAGES)
	cp -a extra/* images documents fonts build/out/

deploy: deploy-prepare
	rsync --delete -r build/out/ contact.mpi-sws.org:/www/sws-homepage/antoinek/

build/main.css: templates/main.scss
	@mkdir -p $(dir $@)
	$(SASS) $< >$@

build/singleplage.xml: templates/singlepage.xml build/main.css
	@mkdir -p $(dir $@)
	sed -e '/CSS_PLACEHOLDER/ {' -e 'r build/main.css' -e 'd' -e '}' <$< >$@

build/out/atom.xml: templates/atom.xml $(addprefix build/out/,$(BLOG_PAGES))
	@mkdir -p $(dir $@)
	cd build/out && sblg -a -t ../../$< -o ../../$@ $(BLOG_PAGES)

build/out/%.html: pages/%.xml $(TEMPLATE)
	@mkdir -p $(dir $@)
	sed -e '/<article data-sblg-article="1" \/>/ {' -e 'r $<' -e 'd' -e '}'\
	  <$(TEMPLATE) >$@

build/out/%.html: build/%.intermediate.xml $(addprefix build/out/,$(BLOG_PAGES)) \
		$(TEMPLATE)
	@mkdir -p $(dir $@)
	cd build/out && sblg -t ../../$< -o ../../$@ $(BLOG_PAGES)

build/out/blogs/%.html: blogs/%.xml $(TEMPLATE)
	@mkdir -p $(dir $@)
	sblg -t $(TEMPLATE) -c -o $@ $<

build/%.intermediate.xml: %.xml $(addprefix build/out/,$(BLOG_PAGES))
	sed -e '/<article data-sblg-article="1" \/>/ {' -e 'r $<' -e 'd' -e '}'\
	  <$(TEMPLATE) >$@
