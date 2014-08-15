require "#{File.expand_path(File.dirname(__FILE__))}/spec_helper"
require "validates_email_format_of"

describe ValidatesEmailFormatOf do
  before(:all) do
    described_class.load_i18n_locales
    I18n.enforce_available_locales = false
  end
  subject do |example|
    if defined?(ActiveModel)
      user = Class.new do
        def initialize(email)
          @email = email
        end
        attr_reader :email
        include ActiveModel::Validations
        validates_email_format_of :email, example.example_group_instance.options
      end
      example.example_group_instance.class::User = user
      user.new(example.example_group_instance.email).tap(&:valid?).errors.full_messages
    else
      ValidatesEmailFormatOf::validate_email_format(email, options)
    end
  end
  let(:options) { {} }
  let(:email) { |example| example.example_group.description }
  describe "no_at_symbol" do
    it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
  end
  describe "user1@gmail.com" do
    it { should_not have_errors_on_email }
  end

  [
    'valid@example.com',
    'Valid@test.example.com',
    'valid+valid123@test.example.com',
    'valid_valid123@test.example.com',
    'valid-valid+123@test.example.co.uk',
    'valid-valid+1.23@test.example.com.au',
    'valid@example.co.uk',
    'v@example.com',
    'valid@example.ca',
    'valid_@example.com',
    'valid123.456@example.org',
    'valid123.456@example.travel',
    'valid123.456@example.museum',
    'valid@example.mobi',
    'valid@example.info',
    'valid-@example.com',
    'fake@p-t.k12.ok.us',
    # allow single character domain parts
    'valid@mail.x.example.com',
    'valid@x.com',
    'valid@example.w-dash.sch.uk',
    # from RFC 3696, page 6
    'customer/department=shipping@example.com',
    '$A12345@example.com',
    '!def!xyz%abc@example.com',
    '_somename@example.com',
    # apostrophes
    "test'test@example.com",
    # international domain names
    'test@xn--bcher-kva.ch',
    'test@example.xn--0zwm56d',
    'test@192.192.192.1'
  ].each do |address|
    describe address do
      it { should_not have_errors_on_email }
    end
  end
end
