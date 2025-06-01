SitemapGenerator::Sitemap.default_host = "http://brgen.no"

SitemapGenerator::Sitemap.create do
  Forem::Forum.all.each do |forum|
    add(forum.slug)
  end

  Forem::Topic.all.each do |topic|
    add(topic.slug)
  end
end

