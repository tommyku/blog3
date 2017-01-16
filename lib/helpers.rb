include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging
include Nanoc::Helpers::LinkTo

def preview?(item)
  item[:preview] && item[:preview] == true
end

def special?(item)
  item[:special] && item[:special] == true
end

def sorted_special_articles
  sorted_articles.select { |item| special?(item) && !preview?(item) }
end

def abstract?(item)
  !item[:abstract].nil?
end

def abstract(item)
  item[:abstract]
end
