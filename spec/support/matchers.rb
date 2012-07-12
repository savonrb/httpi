RSpec::Matchers.define :match_response do |options|
  defaults = { :code => 200, :headers => { "Accept-encoding" => "utf-8" }, :body => "" }
  response = defaults.merge options

  match do |actual|
    actual.should be_an(HTTPI::Response)
    actual.code.should == response[:code]
    downcase(actual.headers).should == downcase(response[:headers])
    actual.body.should == response[:body]
  end

  def downcase(hash)
    hash.inject({}) do |memo, (key, value)|
      memo[key.downcase] = value.downcase
      memo
    end
  end

end
