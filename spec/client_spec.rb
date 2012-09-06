require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Client" do

  context "configuration" do
  end

  context "requests" do

    let(:service_double){ double "service" }
    let(:api_client){ Droplr::Client.new({}) }

    before(:each) do
      Droplr::Client.any_instance.stub(:check_client_configuration)
      Droplr::Client.any_instance.stub(:handle_json_response)
      Droplr::Client.any_instance.stub(:handle_header_response)
      Droplr::Configuration.stub(:new)
      Droplr::Service.stub(:new).and_return(service_double)
    end

    context "#list_drops" do

      it "allows searching drops" do
        service_double.should_receive(:list_drops).with(:search => "find 'em")
        api_client.list_drops(:search => "find 'em")
      end

      it "throws a fit with an invalid parameter" do
        lambda { api_client.list_drops(:orangutangs => "bananas") }.should raise_error(Droplr::RequestError)
      end

    end

  end

end