module HowitzerStat
  class WebServer < Sinatra::Base

    # -- Configuration --
    before do
      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['GET']
    end

    set :methodoverride, true
    set :protection, false
    set :public_folder, File.join(File.dirname(__FILE__), '..', '..', 'client', 'full')

    # -- Sinatra helpers --

    def self.put_or_post(*a, &b)
      put *a, &b
      post *a, &b
    end

    helpers do
      def json_status(code, reason)
        status code
        {
            :status => code,
            :reason => reason
        }.to_json
      end

      def accept_params(params, *fields)
        h = { }
        fields.each do |name|
          h[name] = params[name] if params[name]
        end
        h
      end

      def dc
        HowitzerStat.data_cacher
      end

      def pi
        HowitzerStat.page_identifier
      end
    end

    # --  API  --

    get '/pages/:page_class', :provides => :json do
      content_type :json
      if dc.page_cached?(params[:page_class])
        status 200
        dc.get(params[:page_class]).to_json
      else
        json_status 404, "Page '#{params[:page_class]}' was not found"
      end
    end

    get '/page_classes', :provides => :json do
      content_type :json
      status 200
      if params[:url] && params[:title]
        {page: pi.identify_page(params[:url], params[:title])}.to_json
      else
        pi.all_pages.to_json
      end
    end

    get '/test' do
      IO.read('/Users/romikoops/RubyWS/personal/howitzer_stat/client/layout.html')
    end

    # -- misc handlers: error, not_found, etc. --
    get "*" do
      status 404
    end

    put_or_post "*" do
      status 404
    end

    delete "*" do
      status 404
    end

    #not_found do
    #  json_status 404, "Not found"
    #end

    error do
      json_status 500, env['sinatra.error'].message
    end
  end
end