require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Client" do

  let(:authenticated_client){
      Droplr::Client.new({
      :token           => "user_1@droplr.com",
      :secret          => OpenSSL::Digest::SHA1.hexdigest("pass_1"),
      :use_production  => false,
      :app_public_key  => "app_0_publickey",
      :app_private_key => "app_0_privatekey",
      :user_agent      => 'DroplrWebTests/1.0.3'
    })
  }

  context "Accounts" do

    context "Reading account information" do

      it "gets correct values" do
        response = authenticated_client.read_account_details

        response.should_not be_nil
        response["id"].should_not be_nil
        response["createdat"].should_not be_nil
        response["type"].should_not be_nil
        response["subscriptionend"].should_not be_nil
        response["maxuploadsize"].should_not be_nil
        response["extraspace"].should_not be_nil
        response["usedspace"].should_not be_nil
        response["totalspace"].should_not be_nil
        response["email"].should_not be_nil
        response["usedomain"].should_not be_nil
        response["userootredirect"].should_not be_nil
        response["dropprivacy"].should_not be_nil
        response["theme"].should_not be_nil
        response["dropcount"].should_not be_nil
      end

    end

  end

  context "Drops" do

    context "Reading drops" do

      it "reads an uploaded drop" do
        link     = authenticated_client.shorten_link("http://example.com")
        response = authenticated_client.read_drop(link["code"])

        response.should_not be_nil
        response["code"].should_not be_nil
        response["createdat"].should_not be_nil
        response["type"].should_not be_nil
        response["title"].should_not be_nil
        response["views"].should_not be_nil
        response["lastaccess"].should_not be_nil
        response["size"].should_not be_nil
        response["createdat"].should_not be_nil
        response["privacy"].should_not be_nil
        response["password"].should_not be_nil
        response["obscurecode"].should_not be_nil
        response["shortlink"].should_not be_nil
      end

      it "reads an uploaded drop anonymously" do
        link     = authenticated_client.shorten_link("http://example.com")
        response = authenticated_client.read_drop(link["code"], {:use_anonymous => true})

        response.should_not be_nil
        response["code"].should_not be_nil
        response["createdat"].should_not be_nil
        response["type"].should_not be_nil
        response["title"].should_not be_nil
        response["views"].should_not be_nil
        response["lastaccess"].should_not be_nil
        response["size"].should_not be_nil
        response["filecreatedat"].should_not be_nil
        response["privacy"].should_not be_nil
        response["password"].should_not be_nil
        response["obscurecode"].should_not be_nil
        response["shortlink"].should_not be_nil
      end

    end

    context "Shortening a link" do

      it "returns the uploaded link drop" do
        response = authenticated_client.shorten_link("https://github.com/technoweenie/faraday")

        response.should_not be_nil
        response["code"].should_not be_nil
        response["createdat"].should_not be_nil
        response["type"].should_not be_nil
        response["title"].should_not be_nil
        response["size"].should_not be_nil
        response["privacy"].should_not be_nil
        response["password"].should_not be_nil
        response["obscurecode"].should_not be_nil
        response["shortlink"].should_not be_nil
        response["usedspace"].should_not be_nil
        response["totalspace"].should_not be_nil
      end

    end

    context "Creating a note" do

      it "returns the uploaded note drop with a default of plain" do
        response = authenticated_client.create_note("testing a note drop")

        response.should_not be_nil
        response["code"].should_not be_nil
        response["createdat"].should_not be_nil
        response["type"].should_not be_nil
        response["title"].should_not be_nil
        response["size"].should_not be_nil
        response["privacy"].should_not be_nil
        response["password"].should_not be_nil
        response["obscurecode"].should_not be_nil
        response["shortlink"].should_not be_nil
        response["usedspace"].should_not be_nil
        response["totalspace"].should_not be_nil

        response["variant"].should == "plain"
      end

      it "can create a markdown drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "markdown"})

        response["variant"].should == "markdown"
      end

      it "can create a code drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "code"})

        response["variant"].should == "code"
      end

      it "can create a textile drop" do
        response = authenticated_client.create_note("testing a note drop", {:variant => "textile"})

        response["variant"].should == "textile"
      end

    end

    context "Uploading a file" do

      it "returns the uploaded file drop" do
        pending "pass in a file and actually do this"
        # response = authenticated_client.upload_file(file)

        # response.should_not be_nil
        # response["code"].should_not be_nil
        # response["createdat"].should_not be_nil
        # response["type"].should_not be_nil
        # response["title"].should_not be_nil
        # response["size"].should_not be_nil
        # response["privacy"].should_not be_nil
        # response["password"].should_not be_nil
        # response["obscurecode"].should_not be_nil
        # response["shortlink"].should_not be_nil
        # response["usedspace"].should_not be_nil
        # response["totalspace"].should_not be_nil
      end

    end

    context "Deleting a drop" do

      it "deletes the drop" do
        link     = authenticated_client.shorten_link("http://example.com")
        response = authenticated_client.delete_drop(link["code"])

        response.status.should == 200
      end

    end

  end

end