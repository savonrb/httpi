RSpec::Matchers.define :match_response do |options|
  defaults = { :code => 200, :headers => {}, :body => "" }
  response = defaults.merge options
  
  match do |actual|
    actual.should be_an(HTTPI::Response)
    actual.code.should == response[:code]
    actual.headers.should == response[:headers]
    actual.body.should == response[:body]
  end
end
