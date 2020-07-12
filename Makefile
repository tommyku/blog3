#!make
include .makeenv
export $(shell sed 's/=.*//' .makeenv)

post: template/preview.md
	cp template/preview.md "./content/preview/$(name).md"

publish: content/preview/$(name).md bin/docker-publish
	sed -i 's/preview: true/preview: false/' "./content/preview/$(name).md"
	mv "./content/preview/$(name).md" "./content/blog/$(name).md"
	if [ -d "./content/assets/preview_images/$(name)" ]; then \
		mv "./content/assets/preview_images/$(name)" "./content/assets/blog_images/$(name)"; \
	fi

download: stage_name download_content download_assets download_move_files stage_update
	rm -rf /tmp/cockpit-*

download_content:
	@echo "Headless CMS URL is '$(HEADLESS_CMS_URL)'"
	@echo "Post to download is '$(shell cat /tmp/cockpit-download-name)'"
	@echo "Downloading post content..."
	curl "$(HEADLESS_CMS_URL)?token=$(HEADLESS_CMS_TOKEN)" -H 'Content-Type: application/json' --data-binary '{"filter": {"title": "$(shell cat /tmp/cockpit-download-name)"}}' --compressed > /tmp/cockpit-blog-download.json
	rm -f /tmp/cockpit-post.md
	@echo "---" >> /tmp/cockpit-post.md
	@echo "title: $(shell jq -r '.entries[0].title' /tmp/cockpit-blog-download.json)" >> /tmp/cockpit-post.md
	@echo "kind: article" >> /tmp/cockpit-post.md
	@echo "created_at: $(shell date +'%Y-%m-%d %H:%M:%S %z')" >> /tmp/cockpit-post.md
	@echo "slug: $(shell jq -r '.entries[0].title' /tmp/cockpit-blog-download.json | tr [:upper:] [:lower:] | tr -d [:cntrl:] | tr -c [:alnum:] '-')" >> /tmp/cockpit-post.md
	@echo "preview: true" >> /tmp/cockpit-post.md
	@echo "abstract: $(shell jq -r '.entries[0].abstract' /tmp/cockpit-blog-download.json)" >> /tmp/cockpit-post.md
	@echo "---" >> /tmp/cockpit-post.md
	@echo "" >> /tmp/cockpit-post.md
	jq -r '.entries[0].body' /tmp/cockpit-blog-download.json >> /tmp/cockpit-post.md

download_assets: /tmp/cockpit-post.md
	mkdir -p /tmp/cockpit-post-assets
	grep -oP \"$(HEADLESS_CMS_HOST_REGEXP).*?\" /tmp/cockpit-post.md | uniq | tr -d \" | (xargs wget -P /tmp/cockpit-post-assets/ || true)
	sed 's/$(HEADLESS_CMS_HOST_REGEXP)\/[^/]\+\/[^/]\+\/[^/]\+\/[^\]\+\/[^\]\+\//.\//' /tmp/cockpit-post.md

download_move_files: /tmp/cockpit-post.md /tmp/cockpit-post-assets
	mv -f /tmp/cockpit-post.md ./content/preview/$(shell jq -r '.entries[0].title' /tmp/cockpit-blog-download.json | tr [:upper:] [:lower:] | tr -d [:cntrl:] | tr -c [:alnum:] '-').md
	rm -rf ./content/assets/preview_images/$(shell jq -r '.entries[0].title' /tmp/cockpit-blog-download.json | tr [:upper:] [:lower:] | tr -d [:cntrl:] | tr -c [:alnum:] '-')
	mv -f /tmp/cockpit-post-assets ./content/assets/preview_images/$(shell jq -r '.entries[0].title' /tmp/cockpit-blog-download.json | tr [:upper:] [:lower:] | tr -d [:cntrl:] | tr -c [:alnum:] '-')

stage_update:
	jq -r '{ data: [(.entries[0] + {IsStaged: true})] }' /tmp/cockpit-blogs-to-stage.json > /tmp/cockpit-blog-stage-update.json
	curl "$(HEADLESS_CMS_UPDATE_STAGE_URL)?token=$(HEADLESS_CMS_TOKEN)" -X POST -H 'Content-Type: application/json' -d @/tmp/cockpit-blog-stage-update.json --compressed

stage_name:
	curl "$(HEADLESS_CMS_STAGE_URL)?token=$(HEADLESS_CMS_TOKEN)" -H 'Content-Type: application/json' --data-binary '{"filter": {"IsStaged": false}}' --compressed > /tmp/cockpit-blogs-to-stage.json
	jq -r '.entries[0].Collection.display' /tmp/cockpit-blogs-to-stage.json > /tmp/cockpit-download-name
