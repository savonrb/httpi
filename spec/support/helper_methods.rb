module HelperMethods

  def some_url
    @some_url ||= "http://example.com"
  end

  def some_headers
    @some_headers ||= [["Content-Type", "text/html; charset=utf-8"]]
  end

  def some_headers_hash
    @some_headers_hash ||= Hash[some_headers]
  end

  def some_html
    @some_html ||= '<!DOCTYPE html><html><head><title>Example Web Page</title></head><body>Example</body></html>'
  end

end
