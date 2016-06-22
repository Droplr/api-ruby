require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Client" do

  context "configuration" do

    context "#check_client_configuration" do

      before(:each) do
        Droplr::Configuration.stub(:new)
        Droplr::Service.stub(:new)
      end

      it "raises an exception with an unexpected password" do
        configs = {:token           => "test_token",
                   :secret          => "too_short_secret",
                   :app_public_key  => "some_public_key",
                   :app_private_key => "some_private_key",
                   :user_agent      => "some_user_agent"}

        lambda { Droplr::Client.new(configs) }.should raise_error(Droplr::ConfigurationError)
      end

      it "raises an exception if not all required options are present" do
        configs = {:token           => "test_token",
                   :secret          => "a" * 40,
                   :app_public_key  => "some_public_key",
                   :app_private_key => "some_private_key",
                   :user_agent      => "some_user_agent"}

        without_token       = configs.reject { |k, v| k == :token }
        without_secret      = configs.reject { |k, v| k == :secret }
        without_public_key  = configs.reject { |k, v| k == :app_public_key }
        without_private_key = configs.reject { |k, v| k == :app_private_key }
        without_user_agent  = configs.reject { |k, v| k == :user_agent }

        lambda { Droplr::Client.new(without_token) }.should raise_error(Droplr::ConfigurationError)
        lambda { Droplr::Client.new(without_secret) }.should raise_error(Droplr::ConfigurationError)
        lambda { Droplr::Client.new(without_public_key) }.should raise_error(Droplr::ConfigurationError)
        lambda { Droplr::Client.new(without_private_key) }.should raise_error(Droplr::ConfigurationError)
        lambda { Droplr::Client.new(without_user_agent) }.should raise_error(Droplr::ConfigurationError)
        lambda { Droplr::Client.new(configs) }.should_not raise_error
      end

    end

  end

  context "requests" do

    let(:service_double){ double "service" }
    let(:api_client){ Droplr::Client.new({}) }

    before(:each) do
      Droplr::Client.any_instance.stub(:check_client_configuration)
      Droplr::Client.any_instance.stub(:handle_json_response)
      Droplr::Client.stub(:was_successful)
      Droplr::Client.any_instance.stub(:handle_header_response)
      Droplr::Configuration.stub(:new)
      Droplr::Service.stub(:new).and_return(service_double)
    end

    context "#edit_account_details" do

      it "throw an error if no parameters are given" do
        lambda { api_client.edit_account_details }.should raise_error(Droplr::UserError)
      end

      it "throws an error if it gets a field it doesn't recognize" do
        lambda { api_client.edit_account_details(:favorite_animal => "orangutangs") }.should raise_error(Droplr::UserError)
      end

      it "allows editing account details" do
        service_double.should_receive(:edit_account_details).with(:domain => "droplrmcdroplr.com")
        api_client.edit_account_details(:domain => "droplrmcdroplr.com")
      end

    end

    context "#list_drops" do

      it "allows searching drops" do
        service_double.should_receive(:list_drops).with(:search => "find 'em")
        api_client.list_drops(:search => "find 'em")
      end

      it "throws a fit with an invalid parameter" do
        lambda { api_client.list_drops(:orangutangs => "bananas") }.should raise_error(Droplr::UserError)
      end

    end

    context "#read_team" do

      it "throw an error if no parameters are given" do
        lambda { api_client.read_team }.should raise_error(Droplr::UserError)
      end

      it "allows reading a team" do
        service_double.should_receive(:read_team).with("12345")
        api_client.read_team("12345")
      end

    end

    context "#read_drop" do

      it "throw an error if no parameters are given" do
        lambda { api_client.read_drop }.should raise_error(Droplr::UserError)
      end

      it "allows reading a drop" do
        service_double.should_receive(:read_drop).with("12345")
        api_client.read_drop("12345")
      end

    end

    context "#shorten_link" do

      it "throws an error if no parameters are given" do
        lambda { api_client.shorten_link }.should raise_error(Droplr::UserError)
      end

      it "throws an error if the URL is invalid" do
        lambda { api_client.shorten_link("http://hithere").should raise_error(Droplr::UserError) }
      end

      it "allows shortening a link" do
        service_double.should_receive(:shorten_link).with("http://dropdropdroplr.com")
        api_client.shorten_link("http://dropdropdroplr.com")
      end

    end

    context "#create_note" do

      it "throws an error if no note contents are given" do
        lambda { api_client.create_note(nil, :variant => "plain") }.should raise_error(Droplr::UserError)
      end

      it "throws an error if an invalid variant is given" do
        lambda { api_client.create_note("some note contents", :variant => "lettersandstuff").should raise_error(Droplr::UserError) }
      end

      it "allows creating a note" do
        service_double.should_receive(:create_note).with("12345", :variant => "markdown")
        api_client.create_note("12345", :variant => "markdown")
      end

    end

    context "#upload_file" do

      it "throws an error if the file is empty" do
        lambda { api_client.upload_file(nil, :filename => "somename", :content_type => "mp4") }.should raise_error(Droplr::UserError)
      end

      it "throws an error if no filename is given" do
        lambda { api_client.upload_file("abcd", :content_type => "mp4") }.should raise_error(Droplr::UserError)
      end

      it "throws an error if no content-type is given" do
        lambda { api_client.upload_file("abcd", :filename => "somename") }.should raise_error(Droplr::UserError)
      end

      it "allows uploading a file" do
        service_double.should_receive(:upload_file).with("12345", :filename => "somename", :content_type => "mp4")
        api_client.upload_file("12345", :filename => "somename", :content_type => "mp4")
      end

    end

    context "#delete_drop" do

      it "throws an error if no code is given to delete" do
        lambda { api_client.delete_drop }.should raise_error(Droplr::UserError)
      end

      it "allows deleitng a file" do
        service_double.should_receive(:delete_drop).with("12345")
        api_client.delete_drop("12345")
      end

    end

  end

end
