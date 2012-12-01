module ErrorHelper

  class Expectation

    def initialize(error, spec)
      @error = error
      @spec = spec
    end

    def to(tag_error)
      @spec.expect(@error).to @spec.be_a(tag_error)
    end

  end

  def expect_error(error_to_raise, message)
    fake_error(error_to_raise, message)
  rescue => error
    Expectation.new(error, self)
  end

  def be_tagged_with(tag_error)
    tag_error
  end

end
