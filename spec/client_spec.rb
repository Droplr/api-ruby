require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Client" do

  # TODO : stop using real credentials here, and stop uploading drops all the time. stub stuff.
  let(:authenticated_client){
    Droplr::Client.new({
      :token           => "user_2@droplr.com",
      :secret          => OpenSSL::Digest::SHA1.hexdigest("pass_2"),
      :use_production  => false,
      :app_public_key  => "app_0_publickey",
      :app_private_key => "app_0_privatekey",
      :user_agent      => 'DroplrWebTests/1.0.3'
    })
  }

  context "Connections" do

    it "will explicitly instruct to hash a password" do
      lambda{
        Droplr::Client.new({
          :token           => "user_2@droplr.com",
          :secret          => "pass_2",
          :use_production  => false,
          :app_public_key  => "app_0_publickey",
          :app_private_key => "app_0_privatekey",
          :user_agent      => 'DroplrWebTests/1.0.3'
        })
      }.should raise_error(Droplr::ConfigurationError, /SHA1/)
    end

    it "won't create an instance with missing params" do
      lambda{
        Droplr::Client.new({
          :use_production  => false,
          :app_public_key  => "app_0_publickey",
          :user_agent      => 'DroplrWebTests/1.0.3'
        })
      }.should raise_error(Droplr::ConfigurationError, /required/)
    end

  end

  context "Accounts" do

    context "Reading account information" do

      it "gets correct values" do
        response = authenticated_client.read_account_details

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:account][:id].should_not be_nil
        response[:account][:created_at].should be_an(Integer)
        response[:account][:type].should_not be_nil
        response[:account][:subscription_end].should be_an(Integer)
        response[:account][:max_upload_size].should be_an(Integer)
        response[:account][:extra_space].should be_an(Integer)
        response[:account][:used_space].should be_an(Integer)
        response[:account][:total_space].should be_an(Integer)
        response[:account][:email].should_not be_nil
        response[:account][:use_domain].should satisfy {|f| [true, false].include?(f) }
        response[:account][:use_root_redirect].should satisfy {|f| [true, false].include?(f) }
        response[:account][:drop_privacy].should_not be_nil
        response[:account][:theme].should_not be_nil
        response[:account][:drop_count].should be_an(Integer)
      end

    end

    context "Setting account information" do

      it "updates a user's account" do
        response = authenticated_client.edit_account_details({:theme => "light"})

        response.should_not be_nil
        response[:account][:theme].should == "light"
      end

      it "raises an exception if no options are passed to update" do
        lambda{
          authenticated_client.edit_account_details
        }.should raise_error(Droplr::RequestError, /account/)
      end

    end

  end

  context "Drops" do

    context "Reading drops" do

      it "reads an uploaded drop" do
        link     = authenticated_client.shorten_link("http://example.com")
        response = authenticated_client.read_drop(link[:drop][:code])

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drop][:code].should_not be_nil
        response[:drop][:created_at].should_not be_nil
        response[:drop][:type].should_not be_nil
        response[:drop][:title].should_not be_nil
        response[:drop][:views].should_not be_nil
        response[:drop][:last_access].should_not be_nil
        response[:drop][:size].should_not be_nil
        response[:drop][:privacy].should_not be_nil
        response[:drop][:password].should_not be_nil
        response[:drop][:obscure_code].should_not be_nil
        response[:drop][:shortlink].should_not be_nil

        authenticated_client.delete_drop(link[:drop][:code])
      end

      it "raises an exception if no code is passed to read" do
        lambda{
          authenticated_client.read_drop
        }.should raise_error(Droplr::RequestError, /drop/)
      end

    end

    context "Listing drops" do

      it "lists a user's drops" do
        response = authenticated_client.list_drops

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drops].length.should == 10
        response[:drops][0][:obscure_code].should_not be_nil
      end

      it "sorts drops by ascending name" do
        response = authenticated_client.list_drops({:sort_by => "title", :order => "asc"})

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drops].length.should == 10
      end

    end

    context "Shortening a link" do

      it "returns the uploaded link drop" do
        response = authenticated_client.shorten_link("https://github.com/technoweenie/faraday")

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drop][:code].should_not be_nil
        response[:drop][:created_at].should_not be_nil
        response[:drop][:type].should_not be_nil
        response[:drop][:title].should_not be_nil
        response[:drop][:size].should_not be_nil
        response[:drop][:privacy].should_not be_nil
        response[:drop][:password].should_not be_nil
        response[:drop][:obscure_code].should_not be_nil
        response[:drop][:shortlink].should_not be_nil
        response[:drop][:used_space].should_not be_nil
        response[:drop][:total_space].should_not be_nil

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "raises an exception if no link is passed to shorten" do
        lambda{
          authenticated_client.shorten_link
        }.should raise_error(Droplr::RequestError, /link/)
      end

      it "raises an exception if an invalid URL is passed in" do
        lambda{
          authenticated_client.shorten_link("notaurl")
        }.should raise_error(Droplr::RequestError, /invalid/)
      end
    end

    context "Creating a note" do

      it "returns the uploaded note drop with a default of plain" do
        response = authenticated_client.create_note("testing a note drop")

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drop][:code].should_not be_nil
        response[:drop][:created_at].should_not be_nil
        response[:drop][:type].should_not be_nil
        response[:drop][:variant].should == "plain"
        response[:drop][:title].should_not be_nil
        response[:drop][:size].should_not be_nil
        response[:drop][:privacy].should_not be_nil
        response[:drop][:obscure_code].should_not be_nil
        response[:drop][:shortlink].should_not be_nil
        response[:drop][:used_space].should_not be_nil
        response[:drop][:total_space].should_not be_nil

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "can create a markdown drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "markdown"})

        response[:drop][:variant].should == "markdown"

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "can create a code drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "code"})

        response[:drop][:variant].should == "code"

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "can create a textile drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "textile"})

        response[:drop][:variant].should == "textile"

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "raises an exception if no note content is provided" do
        lambda{
          authenticated_client.create_note("", {:variant => "plain"})
        }.should raise_error(Droplr::RequestError, /contents/)
      end

      it "raises an exception if the user specifies an unacceptable variant" do
        lambda{
          authenticated_client.create_note("testing a note drop", {:variant => "ponies!"})
        }.should raise_error(Droplr::RequestError, /variant/)
      end

    end

    context "Uploading a file" do

      it "returns the uploaded file drop" do
        path          = File.expand_path(File.dirname(__FILE__) + '/fixtures/droplr-logo.png')
        content_type  = `file --mime -b #{path}`.gsub(/;.*$/, "").chomp
        file          = File.open(path, "rb")
        response      = authenticated_client.upload_file(file.read, {:filename => "A Sample File", :content_type => content_type})

        response.should_not be_nil
        Droplr::Client.was_successful(response).should == true

        response[:drop][:code].should_not be_nil
        response[:drop][:created_at].should_not be_nil
        response[:drop][:type].should_not be_nil
        response[:drop][:title].should_not be_nil
        response[:drop][:size].should_not be_nil
        response[:drop][:privacy].should_not be_nil
        response[:drop][:password].should_not be_nil
        response[:drop][:obscure_code].should_not be_nil
        response[:drop][:shortlink].should_not be_nil
        response[:drop][:used_space].should_not be_nil
        response[:drop][:total_space].should_not be_nil

        authenticated_client.delete_drop(response[:drop][:code])
      end

      it "raises an exception if no file contents are provided" do
        lambda{
          authenticated_client.upload_file("", {:filename => "A Sample File", :content_type => "image/png"})
        }.should raise_error(Droplr::RequestError, /contents/)
      end

      it "raises an exception if no content-type is provided" do
        lambda{
          authenticated_client.upload_file("binary mumbojumbo", {:filename => "A Sample File"})
        }.should raise_error(Droplr::RequestError, /content_type/)
      end

      it "raises an exception if no filename is provided" do
        lambda{
          authenticated_client.upload_file("binary mumbojumbo", {:content_type => "image/png"})
        }.should raise_error(Droplr::RequestError, /filename/)
      end

    end

    context "Deleting a drop" do

      it "deletes the drop" do
        link     = authenticated_client.shorten_link("http://example.com")
        response = authenticated_client.delete_drop(link[:drop][:code])

        Droplr::Client.was_successful(response).should == true
      end

      it "raises an exception if no code is passed in to delete" do
        lambda{
          authenticated_client.delete_drop
        }.should raise_error(Droplr::RequestError, /delete/)
      end

    end

  end

end