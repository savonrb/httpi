RSpec::Matchers.define :be_a_valid_httpi_response do
  match do |actual|
    actual.should be_an(HTTPI::Response)
    actual.code.should == 200
    actual.headers.should be_a(Hash)
    actual.body.should == Fixture.xml
  end
end
