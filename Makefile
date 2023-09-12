PAGES= index projects publications bio

ALL_PAGES= $(addprefix build/out/,$(addsuffix .html,$(PAGES)))

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

build/out/%.html: pages/%.xml $(TEMPLATE)
	@mkdir -p $(dir $@)
	sed -e '/<article data-sblg-article="1" \/>/ {' -e 'r $<' -e 'd' -e '}'\
	  <$(TEMPLATE) >$@
