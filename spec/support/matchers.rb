RSpec::Matchers.define :be_a_valid_httpi_response do
  match do |actual|
    actual.should be_an(HTTPI::Response)
    actual.code.should == Some.response_code
    actual.headers.should == Some.headers
    actual.body.should == Fixture.xml
  end
end
