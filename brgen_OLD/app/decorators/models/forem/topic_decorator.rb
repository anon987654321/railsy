Forem::Topic.class_eval do
  include PgSearch

  pg_search_scope :search, against: [:subject], using: { tsearch: { dictionary: "english" } }, associated_against: { posts: [:text] }

  workflow do
    state :pending_review do
      event :spam,    :transitions_to => :spam
      event :approve, :transitions_to => :approved
    end
    state :spam
    state :approved do
      event :approve, :transitions_to => :approved
      event :publish, :transitions_to => :published
      event :confirm, :transitions_to => :pending_confirmation
    end
    state :pending_confirmation do
      event :publish, :transitions_to => :published
    end
    state :published do
      event :expire, :transitions_to => :expired
    end
    state :expired do
      event :mark_delete, :transitions_to => :deleted
    end
    state :deleted
  end

  # TODO: Permit these attributes for admin

  # attr_accessible :published_at, :expired_at, :ad_confirmation_key, as: :admin

  has_many :flags, as: :flaggable

  has_one :address, class_name: "Address"
  accepts_nested_attributes_for :address

  # validates :location, presence: true, if: Proc.new { |topic| topic.category.events? || topic.category.for_sale? || topic.category.housing? }
  # validates :price, presence: true, if: Proc.new { |topic| topic.category.for_sale? || topic.category.housing? }
  # validates :size, presence: true, if: Proc.new { |topic| topic.category.housing? }

  validate :email_for_ad
  validates :forum, presence: true

  before_save :set_media

  after_create :skip_pending_review
  after_create :subscribe_poster, unless: Proc.new { posts.first.email.blank? }

  after_destroy :update_counter_cache

  # -------------------------------------------------

  # Pretty URLs

  # http://apidock.com/rails/ActiveSupport/Inflector/parameterize

  # Eliminate apostrophes beforehand

  def normalize_friendly_id(string)
    self.to_s.downcase.gsub(/['`]/, "").parameterize
  end

  # -------------------------------------------------

  class << self
    def top
      order("views_count DESC")
    end

    # -------------------------------------------------

    def flagged
      select("forem_topics.*, count(forem_topics.id) AS count_all").
        joins("LEFT JOIN flags ON flaggable_id=forem_topics.id").
        group("flaggable_id").
        order("count_all DESC")
    end

    # -------------------------------------------------

    def newsworthy_regular
      joins(forum: :category).where("forem_categories.newsworthy = ?", true).by_most_recent_post
    end

    def newsworthy_media
      joins(forum: :category).where("forem_categories.newsworthy = ? AND forem_topics.media = ?", true, true).by_most_recent_post
    end

    # -------------------------------------------------

    # Most popular posts equals posts with the most likes

    def popular_regular
      order("forem_topics.likes_count DESC")
    end

    def popular_media
      where("forem_topics.media = ?", true).order("forem_topics.likes_count DESC")
    end

    # -------------------------------------------------

    def sponsored
      where("sponsored = ?", true)
    end

    def not_sponsored
      where("sponsored = ?", false)
    end

    # -------------------------------------------------

    def published
      where("forem_topics.state = ?", "published")
    end

    def published_by_type(forum_type)
      published.joins(:forum => :forum_type).where("forum_types.value = ?", forum_type.value)
    end

    # -------------------------------------------------

    def expired
      where("forem_topics.state = ?", "expired")
    end

    # -------------------------------------------------

    def deleted
      where("forem_topics.state = ?", "deleted")
    end
  end

  # -------------------------------------------------

  def category
    (forum.category.child? ? forum.category.parent : forum.category)
  end

  def forum_type
    forum.forum_type
  end

  def owner_or_admin?(other_user)
    user == other_user || other_user.forem_admin?
  end

  def public_posts
    posts.where("reply_type = ?", "regular")
  end

  def description
    posts.first.text
  end

  def enable_comments
    posts.first.enable_comments
  end

  # -------------------------------------------------

  def likes
    Like.joins(:post => :topic).where("forem_posts.topic_id = ?", id)
  end

  # -------------------------------------------------

  def photo
    posts.first.photos.first
  end

  def photos
    Photo.joins(:post => :topic).where("forem_posts.topic_id = ?", id)
  end

  # -------------------------------------------------

  def publish
    update_attribute(:published_at, DateTime.now)
    forum.update_attribute(:published_topics_count, Forem::Topic.not_sponsored.published.where("forum_id = ?", forum.id).count)
  end

  # -------------------------------------------------

  def email_for_ad
    errors.add("posts.email", t(:cant_be_blank)) if post_type == ForumType.ad.value && posts.first.email.blank?
  end

  def send_ad_forward(post)
    AdMailer.ad_forward(self, post).deliver
  end

  def send_confirm_ad
    AdMailer.ad_confirm(self).deliver
  end

  def confirm
    update_attribute(:ad_confirmation_key, SecureRandom.hex)
    send_confirm_ad
  end

protected
  def skip_pending_review
    approve!
  end

  def update_counter_cache
    self.forum.update_attribute(:published_topics_count, Forem::Topic.not_sponsored.published.where("forum_id = ?", self.forum.id).count)
  end

  # Content from these URLs qualifies for media feed

  # http://embed.ly/tools/generator

  def set_media
    if self.description =~ /((http:\/\/(.*yfrog\..*\/.*|www\.flickr\.com\/photos\/.*|flic\.kr\/.*|twitpic\.com\/.*|www\.twitpic\.com\/.*|twitpic\.com\/photos\/.*|www\.twitpic\.com\/photos\/.*|.*imgur\.com\/.*|twitgoo\.com\/.*|i.*\.photobucket\.com\/albums\/.*|s.*\.photobucket\.com\/albums\/.*|media\.photobucket\.com\/image\/.*|www\.mobypicture\.com\/user\/.*\/view\/.*|moby\.to\/.*|xkcd\.com\/.*|www\.xkcd\.com\/.*|imgs\.xkcd\.com\/.*|www\.asofterworld\.com\/index\.php\?id=.*|www\.asofterworld\.com\/.*\.jpg|asofterworld\.com\/.*\.jpg|www\.qwantz\.com\/index\.php\?comic=.*|23hq\.com\/.*\/photo\/.*|www\.23hq\.com\/.*\/photo\/.*|.*dribbble\.com\/shots\/.*|drbl\.in\/.*|.*\.smugmug\.com\/.*|.*\.smugmug\.com\/.*#.*|picasaweb\.google\.com.*\/.*\/.*#.*|picasaweb\.google\.com.*\/lh\/photo\/.*|picasaweb\.google\.com.*\/.*\/.*|img\.ly\/.*|www\.tinypic\.com\/view\.php.*|tinypic\.com\/view\.php.*|www\.tinypic\.com\/player\.php.*|tinypic\.com\/player\.php.*|www\.tinypic\.com\/r\/.*\/.*|tinypic\.com\/r\/.*\/.*|.*\.tinypic\.com\/.*\.jpg|.*\.tinypic\.com\/.*\.png|meadd\.com\/.*\/.*|meadd\.com\/.*|.*\.deviantart\.com\/art\/.*|.*\.deviantart\.com\/gallery\/.*|.*\.deviantart\.com\/#\/.*|fav\.me\/.*|.*\.deviantart\.com|.*\.deviantart\.com\/gallery|.*\.deviantart\.com\/.*\/.*\.jpg|.*\.deviantart\.com\/.*\/.*\.gif|.*\.deviantart\.net\/.*\/.*\.jpg|.*\.deviantart\.net\/.*\/.*\.gif|www\.fotopedia\.com\/.*\/.*|fotopedia\.com\/.*\/.*|photozou\.jp\/photo\/show\/.*\/.*|photozou\.jp\/photo\/photo_only\/.*\/.*|instagr\.am\/p\/.*|instagram\.com\/p\/.*|skitch\.com\/.*\/.*\/.*|img\.skitch\.com\/.*|www\.questionablecontent\.net\/|questionablecontent\.net\/|www\.questionablecontent\.net\/view\.php.*|questionablecontent\.net\/view\.php.*|questionablecontent\.net\/comics\/.*\.png|www\.questionablecontent\.net\/comics\/.*\.png|twitrpix\.com\/.*|.*\.twitrpix\.com\/.*|www\.someecards\.com\/.*\/.*|someecards\.com\/.*\/.*|some\.ly\/.*|www\.some\.ly\/.*|pikchur\.com\/.*|achewood\.com\/.*|www\.achewood\.com\/.*|achewood\.com\/index\.php.*|www\.achewood\.com\/index\.php.*|www\.whosay\.com\/.*\/content\/.*|www\.whosay\.com\/.*\/photos\/.*|www\.whosay\.com\/.*\/videos\/.*|say\.ly\/.*|ow\.ly\/i\/.*|mlkshk\.com\/p\/.*|lockerz\.com\/s\/.*|pics\.lockerz\.com\/s\/.*|d\.pr\/i\/.*|www\.eyeem\.com\/p\/.*|www\.eyeem\.com\/a\/.*|www\.eyeem\.com\/u\/.*|giphy\.com\/gifs\/.*|gph\.is\/.*|frontback\.me\/p\/.*|www\.fotokritik\.com\/.*\/.*|fotokritik\.com\/.*\/.*|gist\.github\.com\/.*|www\.crunchbase\.com\/.*\/.*|crunchbase\.com\/.*\/.*|www\.slideshare\.net\/.*\/.*|www\.slideshare\.net\/mobile\/.*\/.*|.*\.slideshare\.net\/.*\/.*|slidesha\.re\/.*|scribd\.com\/doc\/.*|www\.scribd\.com\/doc\/.*|scribd\.com\/mobile\/documents\/.*|www\.scribd\.com\/mobile\/documents\/.*|screenr\.com\/.*|polldaddy\.com\/community\/poll\/.*|polldaddy\.com\/poll\/.*|answers\.polldaddy\.com\/poll\/.*|www\.howcast\.com\/videos\/.*|www\.screencast\.com\/.*\/media\/.*|screencast\.com\/.*\/media\/.*|www\.screencast\.com\/t\/.*|screencast\.com\/t\/.*|issuu\.com\/.*\/docs\/.*|www\.kickstarter\.com\/projects\/.*\/.*|www\.scrapblog\.com\/viewer\/viewer\.aspx.*|foursquare\.com\/.*|www\.foursquare\.com\/.*|4sq\.com\/.*|www\.sliderocket\.com\/.*|sliderocket\.com\/.*|app\.sliderocket\.com\/.*|portal\.sliderocket\.com\/.*|beta-sliderocket\.com\/.*|maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|.*\.craigslist\.org\/.*\/.*|my\.opera\.com\/.*\/albums\/show\.dml\?id=.*|my\.opera\.com\/.*\/albums\/showpic\.dml\?album=.*&picture=.*|tumblr\.com\/.*|.*\.tumblr\.com\/post\/.*|www\.polleverywhere\.com\/polls\/.*|www\.polleverywhere\.com\/multiple_choice_polls\/.*|www\.polleverywhere\.com\/free_text_polls\/.*|www\.quantcast\.com\/wd:.*|www\.quantcast\.com\/.*|siteanalytics\.compete\.com\/.*|.*\.status\.net\/notice\/.*|identi\.ca\/notice\/.*|www\.studivz\.net\/Profile\/.*|www\.studivz\.net\/l\/.*|www\.studivz\.net\/Groups\/Overview\/.*|www\.studivz\.net\/Gadgets\/Info\/.*|www\.studivz\.net\/Gadgets\/Install\/.*|www\.studivz\.net\/.*|www\.meinvz\.net\/Profile\/.*|www\.meinvz\.net\/l\/.*|www\.meinvz\.net\/Groups\/Overview\/.*|www\.meinvz\.net\/Gadgets\/Info\/.*|www\.meinvz\.net\/Gadgets\/Install\/.*|www\.meinvz\.net\/.*|www\.schuelervz\.net\/Profile\/.*|www\.schuelervz\.net\/l\/.*|www\.schuelervz\.net\/Groups\/Overview\/.*|www\.schuelervz\.net\/Gadgets\/Info\/.*|www\.schuelervz\.net\/Gadgets\/Install\/.*|www\.schuelervz\.net\/.*|myloc\.me\/.*|pastebin\.com\/.*|pastie\.org\/.*|www\.pastie\.org\/.*|redux\.com\/stream\/item\/.*\/.*|redux\.com\/f\/.*\/.*|www\.redux\.com\/stream\/item\/.*\/.*|www\.redux\.com\/f\/.*\/.*|cl\.ly\/.*|cl\.ly\/.*\/content|speakerdeck\.com\/.*\/.*|www\.kiva\.org\/lend\/.*|www\.timetoast\.com\/timelines\/.*|storify\.com\/.*\/.*|.*meetup\.com\/.*|meetu\.ps\/.*|www\.dailymile\.com\/people\/.*\/entries\/.*|.*\.kinomap\.com\/.*|www\.metacdn\.com\/r\/c\/.*\/.*|www\.metacdn\.com\/r\/m\/.*\/.*|prezi\.com\/.*\/.*|.*\.uservoice\.com\/.*\/suggestions\/.*|formspring\.me\/.*|www\.formspring\.me\/.*|formspring\.me\/.*\/q\/.*|www\.formspring\.me\/.*\/q\/.*|twitlonger\.com\/show\/.*|www\.twitlonger\.com\/show\/.*|tl\.gd\/.*|www\.qwiki\.com\/q\/.*|crocodoc\.com\/.*|.*\.crocodoc\.com\/.*|www\.wikipedia\.org\/wiki\/.*|.*\.wikipedia\.org\/wiki\/.*|www\.wikimedia\.org\/wiki\/File.*|graphicly\.com\/.*\/.*\/.*|360\.io\/.*|www\.behance\.net\/gallery\/.*|behance\.net\/gallery\/.*|www\.jdsupra\.com\/legalnews\/.*|jdsupra\.com\/legalnews\/.*|minilogs\.com\/.*|www\.minilogs\.com\/.*|jsfiddle\.net\/.*|ponga\.com\/.*|list\.ly\/list\/.*|crowdmap\.com\/post\/.*|.*\.crowdmap\.com\/post\/.*|crowdmap\.com\/map\/.*|.*\.crowdmap\.com\/map\/.*|ifttt\.com\/recipes\/.*|weavly\.com\/watch\/.*|www\.weavly\.com\/watch\/.*|tagmotion\.com\/tree\/.*|www\.tagmotion\.com\/tree\/.*|public\.talely\.com\/.*\/.*|polarb\.com\/.*|.*\.polarb\.com\/.*|on\.bubb\.li\/.*|bubb\.li\/.*|.*\.bubb\.li\/.*|embed\.imajize\.com\/.*|giflike\.com\/a\/.*|www\.giflike\.com\/a\/.*|i\.giflike\.com\/.*|rapidengage\.com\/s\/.*|infomous\.com\/node\/.*|stepic\.org\/.*|chirb\.it\/.*|beta\.polstir\.com\/.*\/.*|polstir\.com\/.*\/.*|.*amazon\..*\/gp\/product\/.*|.*amazon\..*\/.*\/dp\/.*|.*amazon\..*\/dp\/.*|.*amazon\..*\/o\/ASIN\/.*|.*amazon\..*\/gp\/offer-listing\/.*|.*amazon\..*\/.*\/ASIN\/.*|.*amazon\..*\/gp\/product\/images\/.*|.*amazon\..*\/gp\/aw\/d\/.*|www\.amzn\.com\/.*|amzn\.com\/.*|www\.shopstyle\.com\/browse.*|www\.shopstyle\.com\/action\/apiVisitRetailer.*|api\.shopstyle\.com\/action\/apiVisitRetailer.*|www\.shopstyle\.com\/action\/viewLook.*|itunes\.apple\.com\/.*|shoplocket\.com\/products\/.*|etsy\.com\/listing\/.*|www\.etsy\.com\/listing\/.*|fiverr\.com\/.*\/.*|www\.fiverr\.com\/.*\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|youtu\.be\/.*|.*\.youtube\.com\/user\/.*|.*\.youtube\.com\/.*#.*\/.*|m\.youtube\.com\/watch.*|m\.youtube\.com\/index.*|.*\.youtube\.com\/profile.*|.*\.youtube\.com\/view_play_list.*|.*\.youtube\.com\/playlist.*|.*twitch\.tv\/.*|.*justin\.tv\/.*\/b\/.*|.*justin\.tv\/.*\/w\/.*|.*twitch\.tv\/.*|.*twitch\.tv\/.*\/b\/.*|www\.ustream\.tv\/recorded\/.*|www\.ustream\.tv\/channel\/.*|www\.ustream\.tv\/.*|ustre\.am\/.*|qik\.com\/video\/.*|qik\.com\/.*|qik\.ly\/.*|.*revision3\.com\/.*|.*\.dailymotion\.com\/video\/.*|.*\.dailymotion\.com\/.*\/video\/.*|collegehumor\.com\/video:.*|collegehumor\.com\/video\/.*|www\.collegehumor\.com\/video:.*|www\.collegehumor\.com\/video\/.*|telly\.com\/.*|www\.telly\.com\/.*|break\.com\/.*\/.*|www\.break\.com\/.*\/.*|vids\.myspace\.com\/index\.cfm\?fuseaction=vids\.individual&videoid.*|www\.myspace\.com\/index\.cfm\?fuseaction=.*&videoid.*|www\.metacafe\.com\/watch\/.*|www\.metacafe\.com\/w\/.*|blip\.tv\/.*\/.*|.*\.blip\.tv\/.*\/.*|video\.google\.com\/videoplay\?.*|video\.yahoo\.com\/watch\/.*\/.*|video\.yahoo\.com\/network\/.*|sports\.yahoo\.com\/video\/.*|.*viddler\.com\/v\/.*|liveleak\.com\/view\?.*|www\.liveleak\.com\/view\?.*|animoto\.com\/play\/.*|dotsub\.com\/view\/.*|www\.overstream\.net\/view\.php\?oid=.*|www\.livestream\.com\/.*|new\.livestream\.com\/.*|www\.worldstarhiphop\.com\/videos\/video.*\.php\?v=.*|worldstarhiphop\.com\/videos\/video.*\.php\?v=.*|bambuser\.com\/v\/.*|bambuser\.com\/channel\/.*|bambuser\.com\/channel\/.*\/broadcast\/.*|www\.schooltube\.com\/video\/.*\/.*|bigthink\.com\/ideas\/.*|bigthink\.com\/series\/.*|sendables\.jibjab\.com\/view\/.*|sendables\.jibjab\.com\/originals\/.*|jibjab\.com\/view\/.*|www\.xtranormal\.com\/watch\/.*|socialcam\.com\/v\/.*|www\.socialcam\.com\/v\/.*|v\.youku\.com\/v_show\/.*|v\.youku\.com\/v_playlist\/.*|www\.snotr\.com\/video\/.*|snotr\.com\/video\/.*|www\.clipfish\.de\/.*\/.*\/video\/.*|www\.myvideo\.de\/watch\/.*|www\.vzaar\.com\/videos\/.*|vzaar\.com\/videos\/.*|www\.vzaar\.tv\/.*|vzaar\.tv\/.*|vzaar\.me\/.*|.*\.vzaar\.me\/.*|coub\.com\/view\/.*|coub\.com\/embed\/.*|www\.streamio\.com\/api\/v1\/.*|streamio\.com\/api\/v1\/.*|vine\.co\/v\/.*|www\.vine\.co\/v\/.*|www\.viddy\.com\/video\/.*|www\.viddy\.com\/.*\/v\/.*|www\.tudou\.com\/programs\/view\/.*|tudou\.com\/programs\/view\/.*|sproutvideo\.com\/videos\/.*|embed\.minoto-video\.com\/.*|iframe\.minoto-video\.com\/.*|play\.minoto-video\.com\/.*|dashboard\.minoto-video\.com\/main\/video\/details\/.*|api\.minoto-video\.com\/publishers\/.*\/videos\/.*|www\.brainshark\.com\/.*\/.*|brainshark\.com\/.*\/.*|23video\.com\/.*|.*\.23video\.com\/.*|goanimate\.com\/videos\/.*|brainsonic\.com\/.*|.*\.brainsonic\.com\/.*|lustich\.de\/videos\/.*|web\.tv\/.*|.*\.web\.tv\/.*|mynet\.com\/video\/.*|www\.mynet\.com\/video\/|izlesene\.com\/video\/.*|www\.izlesene\.com\/video\/|alkislarlayasiyorum\.com\/.*|www\.alkislarlayasiyorum\.com\/.*|59saniye\.com\/.*|www\.59saniye\.com\/.*|zie\.nl\/video\/.*|www\.zie\.nl\/video\/.*|app\.ustudio\.com\/embed\/.*\/.*|www\.whitehouse\.gov\/photos-and-video\/video\/.*|www\.whitehouse\.gov\/video\/.*|wh\.gov\/photos-and-video\/video\/.*|wh\.gov\/video\/.*|www\.hulu\.com\/watch.*|www\.hulu\.com\/w\/.*|www\.hulu\.com\/embed\/.*|hulu\.com\/watch.*|hulu\.com\/w\/.*|.*crackle\.com\/c\/.*|www\.funnyordie\.com\/videos\/.*|www\.funnyordie\.com\/m\/.*|funnyordie\.com\/videos\/.*|funnyordie\.com\/m\/.*|www\.vimeo\.com\/groups\/.*\/videos\/.*|www\.vimeo\.com\/.*|vimeo\.com\/groups\/.*\/videos\/.*|vimeo\.com\/.*|vimeo\.com\/m\/#\/.*|player\.vimeo\.com\/.*|www\.ted\.com\/talks\/.*\.html.*|www\.ted\.com\/talks\/lang\/.*\/.*\.html.*|www\.ted\.com\/index\.php\/talks\/.*\.html.*|www\.ted\.com\/index\.php\/talks\/lang\/.*\/.*\.html.*|.*nfb\.ca\/film\/.*|www\.thedailyshow\.com\/watch\/.*|www\.thedailyshow\.com\/full-episodes\/.*|www\.thedailyshow\.com\/collection\/.*\/.*\/.*|movies\.yahoo\.com\/movie\/.*\/video\/.*|movies\.yahoo\.com\/movie\/.*\/trailer|movies\.yahoo\.com\/movie\/.*\/video|www\.colbertnation\.com\/the-colbert-report-collections\/.*|www\.colbertnation\.com\/full-episodes\/.*|www\.colbertnation\.com\/the-colbert-report-videos\/.*|www\.comedycentral\.com\/videos\/index\.jhtml\?.*|www\.theonion\.com\/video\/.*|theonion\.com\/video\/.*|wordpress\.tv\/.*\/.*\/.*\/.*\/|www\.traileraddict\.com\/trailer\/.*|www\.traileraddict\.com\/clip\/.*|www\.traileraddict\.com\/poster\/.*|www\.trailerspy\.com\/trailer\/.*\/.*|www\.trailerspy\.com\/trailer\/.*|www\.trailerspy\.com\/view_video\.php.*|fora\.tv\/.*\/.*\/.*\/.*|www\.spike\.com\/video\/.*|www\.gametrailers\.com\/video.*|gametrailers\.com\/video.*|www\.koldcast\.tv\/video\/.*|www\.koldcast\.tv\/#video:.*|mixergy\.com\/.*|video\.pbs\.org\/video\/.*|www\.zapiks\.com\/.*|www\.trutv\.com\/video\/.*|www\.nzonscreen\.com\/title\/.*|nzonscreen\.com\/title\/.*|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|confreaks\.net\/videos\/.*|www\.confreaks\.net\/videos\/.*|confreaks\.com\/videos\/.*|www\.confreaks\.com\/videos\/.*|video\.allthingsd\.com\/video\/.*|videos\.nymag\.com\/.*|aniboom\.com\/animation-video\/.*|www\.aniboom\.com\/animation-video\/.*|grindtv\.com\/.*\/video\/.*|www\.grindtv\.com\/.*\/video\/.*|ifood\.tv\/recipe\/.*|ifood\.tv\/video\/.*|ifood\.tv\/channel\/user\/.*|www\.ifood\.tv\/recipe\/.*|www\.ifood\.tv\/video\/.*|www\.ifood\.tv\/channel\/user\/.*|logotv\.com\/video\/.*|www\.logotv\.com\/video\/.*|lonelyplanet\.com\/Clip\.aspx\?.*|www\.lonelyplanet\.com\/Clip\.aspx\?.*|streetfire\.net\/video\/.*\.htm.*|www\.streetfire\.net\/video\/.*\.htm.*|sciencestage\.com\/v\/.*\.html|sciencestage\.com\/a\/.*\.html|www\.sciencestage\.com\/v\/.*\.html|www\.sciencestage\.com\/a\/.*\.html|link\.brightcove\.com\/services\/player\/bcpid.*|wirewax\.com\/.*|www\.wirewax\.com\/.*|canalplus\.fr\/.*|www\.canalplus\.fr\/.*|www\.vevo\.com\/watch\/.*|www\.vevo\.com\/video\/.*|pixorial\.com\/watch\/.*|www\.pixorial\.com\/watch\/.*|spreecast\.com\/events\/.*|www\.spreecast\.com\/events\/.*|showme\.com\/sh\/.*|www\.showme\.com\/sh\/.*|.*\.looplogic\.com\/.*|on\.aol\.com\/video\/.*|on\.aol\.com\/playlist\/.*|videodetective\.com\/.*\/.*|www\.videodetective\.com\/.*\/.*|khanacademy\.org\/.*|www\.khanacademy\.org\/.*|.*vidyard\.com\/.*|www\.veoh\.com\/watch\/.*|veoh\.com\/watch\/.*|.*\.univision\.com\/.*\/video\/.*|.*\.vidcaster\.com\/.*|muzu\.tv\/.*|www\.muzu\.tv\/.*|vube\.com\/.*\/.*|www\.vube\.com\/.*\/.*|.*boxofficebuz\.com\/video\/.*|www\.godtube\.com\/featured\/video\/.*|godtube\.com\/featured\/video\/.*|www\.godtube\.com\/watch\/.*|godtube\.com\/watch\/.*|mediamatters\.org\/mmtv\/.*|www\.clikthrough\.com\/theater\/video\/.*|www\.clipsyndicate\.com\/video\/playlist\/.*\/.*|www\.srf\.ch\/player\/tv\/.*\/video\/.*\?id=.*|www\.srf\.ch\/player\/radio\/.*\/audio\/.*\?id=.*|www\.mpora\.com\/videos\/.*|mpora\.com\/videos\/.*|vice\.com\/.*|www\.vice\.com\/.*|videodonor\.com\/video\/.*|espn\.go\.com\/video\/clip.*|espn\.go\.com\/.*\/story.*|abcnews\.com\/.*\/video\/.*|abcnews\.com\/video\/playerIndex.*|abcnews\.go\.com\/.*\/video\/.*|abcnews\.go\.com\/video\/playerIndex.*|washingtonpost\.com\/wp-dyn\/.*\/video\/.*\/.*\/.*\/.*|www\.washingtonpost\.com\/wp-dyn\/.*\/video\/.*\/.*\/.*\/.*|www\.boston\.com\/video.*|boston\.com\/video.*|www\.boston\.com\/.*video.*|boston\.com\/.*video.*|www\.facebook\.com\/photo\.php.*|www\.facebook\.com\/video\/video\.php.*|www\.facebook\.com\/.*\/posts\/.*|fb\.me\/.*|cnbc\.com\/id\/.*\?.*video.*|www\.cnbc\.com\/id\/.*\?.*video.*|cnbc\.com\/id\/.*\/play\/1\/video\/.*|www\.cnbc\.com\/id\/.*\/play\/1\/video\/.*|cbsnews\.com\/video\/watch\/.*|plus\.google\.com\/.*|www\.google\.com\/profiles\/.*|google\.com\/profiles\/.*|www\.cnn\.com\/video\/.*|edition\.cnn\.com\/video\/.*|money\.cnn\.com\/video\/.*|today\.msnbc\.msn\.com\/id\/.*\/vp\/.*|www\.msnbc\.msn\.com\/id\/.*\/vp\/.*|www\.msnbc\.msn\.com\/id\/.*\/ns\/.*|today\.msnbc\.msn\.com\/id\/.*\/ns\/.*|nbcnews\.com\/.*|www\.nbcnews\.com\/.*|multimedia\.foxsports\.com\/m\/video\/.*\/.*|msn\.foxsports\.com\/video.*|www\.globalpost\.com\/video\/.*|www\.globalpost\.com\/dispatch\/.*|theguardian\.com\/.*\/video\/.*\/.*\/.*\/.*|www\.theguardian\.com\/.*\/video\/.*\/.*\/.*\/.*|guardian\.co\.uk\/.*\/video\/.*\/.*\/.*\/.*|www\.guardian\.co\.uk\/.*\/video\/.*\/.*\/.*\/.*|bravotv\.com\/.*\/.*\/videos\/.*|www\.bravotv\.com\/.*\/.*\/videos\/.*|video\.nationalgeographic\.com\/video\/.*\/.*\/.*\/.*|dsc\.discovery\.com\/videos\/.*|animal\.discovery\.com\/videos\/.*|health\.discovery\.com\/videos\/.*|investigation\.discovery\.com\/videos\/.*|military\.discovery\.com\/videos\/.*|planetgreen\.discovery\.com\/videos\/.*|science\.discovery\.com\/videos\/.*|tlc\.discovery\.com\/videos\/.*|video\.forbes\.com\/fvn\/.*|distrify\.com\/film\/.*|muvi\.es\/.*|video\.foxnews\.com\/v\/.*|video\.foxbusiness\.com\/v\/.*|www\.reuters\.com\/video\/.*|reuters\.com\/video\/.*|live\.huffingtonpost\.com\/r\/segment\/.*\/.*|video\.nytimes\.com\/video\/.*|www\.nytimes\.com\/video\/.*\/.*|nyti\.ms\/.*|www\.vol\.at\/video\/.*|vol\.at\/video\/.*|www\.spiegel\.de\/video\/.*|spiegel\.de\/video\/.*|www\.zeit\.de\/video\/.*|zeit\.de\/video\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|snd\.sc\/.*|open\.spotify\.com\/.*|spoti\.fi\/.*|play\.spotify\.com\/.*|www\.last\.fm\/music\/.*|www\.last\.fm\/music\/+videos\/.*|www\.last\.fm\/music\/+images\/.*|www\.last\.fm\/music\/.*\/_\/.*|www\.last\.fm\/music\/.*\/.*|www\.mixcloud\.com\/.*\/.*\/|www\.radionomy\.com\/.*\/radio\/.*|radionomy\.com\/.*\/radio\/.*|www\.hark\.com\/clips\/.*|www\.rdio\.com\/#\/artist\/.*\/album\/.*|www\.rdio\.com\/artist\/.*\/album\/.*|www\.zero-inch\.com\/.*|.*\.bandcamp\.com\/|.*\.bandcamp\.com\/track\/.*|.*\.bandcamp\.com\/album\/.*|freemusicarchive\.org\/music\/.*|www\.freemusicarchive\.org\/music\/.*|freemusicarchive\.org\/curator\/.*|www\.freemusicarchive\.org\/curator\/.*|www\.npr\.org\/.*\/.*\/.*\/.*\/.*|www\.npr\.org\/.*\/.*\/.*\/.*\/.*\/.*|www\.npr\.org\/.*\/.*\/.*\/.*\/.*\/.*\/.*|www\.npr\.org\/templates\/story\/story\.php.*|huffduffer\.com\/.*\/.*|www\.audioboo\.fm\/boos\/.*|audioboo\.fm\/boos\/.*|boo\.fm\/b.*|www\.xiami\.com\/song\/.*|xiami\.com\/song\/.*|www\.saynow\.com\/playMsg\.html.*|www\.saynow\.com\/playMsg\.html.*|grooveshark\.com\/.*|radioreddit\.com\/songs.*|www\.radioreddit\.com\/songs.*|radioreddit\.com\/\?q=songs.*|www\.radioreddit\.com\/\?q=songs.*|www\.gogoyoko\.com\/song\/.*|hypem\.com\/premiere\/.*|bop\.fm\/s\/.*\/.*))|(https:\/\/(picasaweb\.google\.com.*\/.*\/.*#.*|picasaweb\.google\.com.*\/lh\/photo\/.*|picasaweb\.google\.com.*\/.*\/.*|skitch\.com\/.*\/.*\/.*|img\.skitch\.com\/.*|vidd\.me\/.*|gist\.github\.com\/.*|foursquare\.com\/.*|www\.foursquare\.com\/.*|maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|speakerdeck\.com\/.*\/.*|crocodoc\.com\/.*|.*\.crocodoc\.com\/.*|urtak\.com\/u\/.*|urtak\.com\/clr\/.*|ganxy\.com\/.*|www\.ganxy\.com\/.*|sketchfab\.com\/models\/.*|sketchfab\.com\/show\/.*|ifttt\.com\/recipes\/.*|cloudup\.com\/.*|hackpad\.com\/.*|rapidengage\.com\/s\/.*|stepic\.org\/.*|readtapestry\.com\/s\/.*\/|chirb\.it\/.*|medium\.com\/.*|medium\.com\/.*\/.*|itunes\.apple\.com\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|www\.streamio\.com\/api\/v1\/.*|streamio\.com\/api\/v1\/.*|vine\.co\/v\/.*|www\.vine\.co\/v\/.*|mixbit\.com\/v\/.*|www\.brainshark\.com\/.*\/.*|brainshark\.com\/.*\/.*|brainsonic\.com\/.*|.*\.brainsonic\.com\/.*|www\.reelhouse\.org\/.*|reelhouse\.org\/.*|www\.vimeo\.com\/.*|vimeo\.com\/.*|player\.vimeo\.com\/.*|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|.*\.looplogic\.com\/.*|khanacademy\.org\/.*|www\.khanacademy\.org\/.*|.*vidyard\.com\/.*|.*\.stream\.co\.jp\/apiservice\/.*|.*\.stream\.ne\.jp\/apiservice\/.*|www\.facebook\.com\/photo\.php.*|www\.facebook\.com\/video\/video\.php.*|www\.facebook\.com\/.*\/posts\/.*|fb\.me\/.*|plus\.google\.com\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|open\.spotify\.com\/.*|play\.spotify\.com\/.*)))/i
      self.media = true
    end
  end
end

