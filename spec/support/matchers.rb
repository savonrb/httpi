RSpec::Matchers.define :match_response do |options|
  defaults = { :code => 200, :headers => { "Accept-encoding" => "utf-8" }, :body => "" }
  response = defaults.merge options

  match do |actual|
    expect(actual).to be_an(HTTPI::Response)
    expect(actual.code).to eq(response[:code])
    expect(downcase(actual.headers)).to eq(downcase(response[:headers]))
    expect(actual.body).to eq(response[:body])
  end

  def downcase(hash)
    hash.inject({}) do |memo, (key, value)|
      memo[key.downcase] = value.downcase
      memo
    end
  end

end
