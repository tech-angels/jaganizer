require 'spec_helper'

describe Jaganizer do
  before :each do
    simulate_jagan_responses
  end

  context 'with params' do
    before do
      @parameters = { :param1 => 'param1', :param2 => 2 }
      Jaganizer.request('test', @parameters)
    end

    it 'does a post request with correct HTTP auth credentials' do
      WebMock.should have_requested(:post, jaganizer_url_for('test'))
                .with(:body => @parameters, :headers => {'Content-Type'=>'application/json'}).once
    end
  end

  context 'without params' do
    before do
      Jaganizer.request('test')
    end

    it 'does a get request with correct HTTP auth credentials' do
      WebMock.should have_requested(:get, jaganizer_url_for('test')).once
    end
  end
end