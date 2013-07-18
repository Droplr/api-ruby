require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Service" do

  # we are going to test faraday_stub.run_request's params because we can be sure the auth
  # header has been built by then. and if we got that right, we probably got the method right.
  let(:faraday_stub){ double("faraday", :url => "http://test.host") }
  let(:api_client){ Droplr::Client.new({:token           => "test_token",
                                        :secret          => "a" * 40,
                                        :app_public_key  => "some_public_key",
                                        :app_private_key => "some_private_key",
                                        :user_agent      => "some_user_agent"}) }

  before(:each) do
    # we calculate the time in our header signatures, and this ensures we remove variation
    Time.stub(:now).and_return(134434487300)
    Droplr::Service.any_instance.stub(:base_request).and_return(faraday_stub)
  end

  context "#read_account_details" do

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:uJbNNRu9FH+/4QOeNcBFwEb5WUo="
      faraday_stub.should_receive(:run_request).with(:get, "/account.json", nil, hash_including("Authorization" => expected_auth_string))

      api_client.service.read_account_details
    end

    it "sets no content-type because it's a read operation" do
      faraday_stub.should_receive(:run_request).with(:get, "/account.json", nil, hash_not_including("Content-Type"))

      api_client.service.read_account_details
    end

  end

  context "#edit_account_details" do

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:dZ+ux4PpUunEk8L7fi60v2oyubI="
      faraday_stub.should_receive(:run_request).with(:put, "/account.json", {}, hash_including("Authorization" => expected_auth_string))

      api_client.service.edit_account_details({})
    end

    it "properly sets the JSON body" do
      faraday_stub.should_receive(:run_request).with(:put, "/account.json", hash_including({:theme => "LIGHT", :dropprivacy => "PRIVATE"}), kind_of(Hash))

      api_client.service.edit_account_details({:theme => "LIGHT", :dropprivacy => "PRIVATE"})
    end

    it "sets the appropriate content-type header" do
      faraday_stub.should_receive(:run_request).with(:put, "/account.json", kind_of(Hash), hash_including("Content-Type" => "application/json"))

      api_client.service.edit_account_details({})
    end

  end

  context "#read_drop" do

    it "builds a request and authentication header correctly" do
      drop_code            = "1234"
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:3FgNnvGEPbEiC8GE/1hj3BL3ats="
      faraday_stub.should_receive(:run_request).with(:get, "/drops/#{drop_code}.json", nil, hash_including("Authorization" => expected_auth_string))

      api_client.service.read_drop(drop_code)
    end

  end

  context "#list_drops" do

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:Rlt/6Zqq0NSzFayUlPgqgcok7Gc="
      faraday_stub.should_receive(:run_request).with(:get, "/drops.json?offset=50&sortBy=CREATION", nil, hash_including("Authorization" => expected_auth_string))

      api_client.service.list_drops({:offset => 50, :sortBy => "CREATION"})
    end

    it "sets the appropriate content-type" do
      faraday_stub.should_receive(:run_request).with(:get, "/drops.json?offset=50&sortBy=CREATION", nil, hash_including("Content-Type" => "application/json"))

      api_client.service.list_drops({:offset => 50, :sortBy => "CREATION"})
    end

  end

  context "#shorten_link" do

    let(:link_to_shorten){ "https://droplr.com/hello" }

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:Aqg8ymoiX9wLyTkYfkOEt8APEEc="
      faraday_stub.should_receive(:run_request).with(:post, "/links.json", link_to_shorten, hash_including("Authorization" => expected_auth_string))

      api_client.service.shorten_link(link_to_shorten)
    end

    it "sets the appropriate content-type" do
      faraday_stub.should_receive(:run_request).with(:post, "/links.json", link_to_shorten, hash_including("Content-Type" => "text/plain"))

      api_client.service.shorten_link(link_to_shorten)
    end

  end

  context "#create_note" do

    let(:note_content){ "some big long string" }

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:qTrB8dLRmdxR9zABZfJIBWeXqOk="
      faraday_stub.should_receive(:run_request).with(:post, "/notes.json", note_content, hash_including("Authorization" => expected_auth_string))

      api_client.service.create_note(note_content, {})
    end

    it "sets the appropriate content-type" do
      faraday_stub.should_receive(:run_request).with(:post, "/notes.json", note_content, hash_including("Content-Type" => "text/markdown"))

      api_client.service.create_note(note_content, {:variant => "markdown"})
    end

  end

  context "#upload_file" do

    let(:file_content){ "some big long string" }
    let(:content_type){ "application/octet-stream" }
    let(:file_title){ "Some File Title" }
    let(:request_options){ {:content_type => content_type, :filename => file_title} }

    it "builds a request and authentication header correctly" do
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:TU2+2Di+LbY+f7roPGsm4Bx6bUw="
      faraday_stub.should_receive(:run_request).with(:post, "/files.json", file_content, hash_including("Authorization" => expected_auth_string))

      api_client.service.upload_file(file_content, request_options)
    end

    it "sets the appropriate content-type and filename" do
      faraday_stub.should_receive(:run_request).with(:post, "/files.json", file_content, hash_including("Content-Type" => content_type, "x-droplr-filename" => file_title))

      api_client.service.upload_file(file_content, request_options)
    end

  end

  context "#delete_drop" do

    it "builds a request and authentication header correctly" do
      drop_code            = "1234"
      expected_auth_string = "droplr c29tZV9wdWJsaWNfa2V5OnRlc3RfdG9rZW4=:8XACRGJwdWgSKuI4UL9kptMhLqA="
      faraday_stub.should_receive(:run_request).with(:delete, "/drops/#{drop_code}", nil, hash_including("Authorization" => expected_auth_string))

      api_client.service.delete_drop(drop_code)
    end

  end

end