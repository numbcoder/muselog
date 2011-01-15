module Toto
	class Article < Hash
		include Template
		def tags 
			self[:tags].to_s.strip.empty? ? ["others"] : self[:tags].split(" ")
		end
		def category
		  self[:category] || "others"
		end
	end
	
	class Tags < Array
		include Template
		def initialize articles, config
      self.replace articles
      @config = config
    end
    
    def to_html
      super(:tags, @config)
    end
	end
	
	class Site
		def tags type = :html
			entries = ! self.articles.empty? ?
        self.articles.reverse.map do |article|
          Article.new article, @config
        end : []
      t = []
      entries.each do |entry|
      	 entry.tags.each{|tag| t << tag}
      end
			return :tags => Tags.new(t, @config)
    end
    
    def tag (name, type = :html)
    	entries = ! self.articles.empty??
        self.articles.select do |a|
          Article.new(a, @config).tags.include?(name)
        end.reverse.map do |article|
          Article.new article, @config
        end : []

      return :archives => Archives.new(entries, @config)
    	#return :tags => Tags.new(["we","gggg", name], @config)
    end
    
    def go route, env = {}, type = :html
      route << self./ if route.empty?
      type, path = type =~ /html|xml|json/ ? type.to_sym : :html, route.join('/')
      context = lambda do |data, page|
        Context.new(data, @config, path, env).render(page, type)
      end

      body, status = if Context.new.respond_to?(:"to_#{type}")
        if route.first =~ /\d{4}/
          case route.size
            when 1..3
              context[archives(route * '-'), :archives]
            when 4
              context[article(route), :article]
            else http 400
          end
        elsif respond_to?(path)
        		#http route.size
          	context[send(path, type), path.to_sym]
        elsif (repo = @config[:github][:repos].grep(/#{path}/).first) &&
              !@config[:github][:user].empty?
          context[Repo.new(repo, @config), :repo]
        elsif respond_to?(route.first)
        	#http route.size
        	context[send(route[0], route[1], type), route.first.to_sym]
        else
          context[{}, path.to_sym]
        end
      else
        http 400
      end

    rescue Errno::ENOENT => e
      return :body => http(404).first, :type => :html, :status => 404
    else
      return :body => body || "", :type => type, :status => status || 200
    end
    
	end
	
end
