post: template/preview.md
	cp template/preview.md "./content/preview/$(name).md"

publish: content/preview/$(name).md bin/docker-publish
	sed -i 's/preview: true/preview: false/' "./content/preview/$(name).md"
	mv "./content/preview/$(name).md" "./content/blog/$(name).md"
	if [ -d "./content/assets/preview_images/$(name)" ]; then \
		mv "./content/assets/preview_images/$(name)" "./content/assets/blog_images/$(name)"; \
	fi
