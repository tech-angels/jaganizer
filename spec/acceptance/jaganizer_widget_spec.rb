require "spec_helper.rb"

feature "Jaganizer widget" do
  before :each do
    simulate_jagan_responses
    visit "/"
  end

  scenario "appears on the page" do
    page.should have_selector "#jaganizer", visible: true
  end

  scenario "chatroom is hidden by default" do
    page.should have_selector ".jaganizer_chatroom", visible: false
  end

  context "with javascript activated", :js => true do
    before :each do
      click_link('Chatroom')
    end

    scenario "clicking on 'chatroom' opens the chatroom" do
      page.should have_selector ".jaganizer_chatroom", visible: true
    end

    scenario "a new user should be added" do
      page.should have_selector ".jaganizer_users li"
    end

    scenario "10 last log messages should be loaded" do
      page.all(".jaganizer_messages li.log").size.should == 10
    end

    context 'sending an empty message' do
      scenario 'do nothing' do
        find('#message').set "\r"
        page.should_not have_selector ".jaganizer_messages li:not[log]"
      end
    end

    context 'sending a non empty message' do
      before :each do
        find('#message').set "Stubbed message !\r"
        @message = page.find(".jaganizer_messages li:last-child .jaganizer_message")
      end

      scenario 'a new message should appear with correct content' do
        @message.text.should == "Stubbed message !"
      end

      scenario 'a new message should appear with correct time' do
        page.should have_content "#{Time.now.strftime('%H')}:#{Time.now.strftime('%M')}"
      end

      scenario 'the message should appears in updater form' do
        page.find('#jaganizer_updater input').value.should == @message[:id]
        page.find('#jaganizer_updater textarea').value.should == "Stubbed message !"
      end
    end

    context 'updating a message' do
      before :each do
        textarea = find('#message')
        textarea.set "Stubbed message !\r"
        textarea.native.send_keys :arrow_up
        find('#updated_message').set "Updated stubbed message !\r"
        @updated_message = page.find('.jaganizer_messages li:last-child .jaganizer_message')
      end

      scenario 'The updated message should replace the old message' do
        @updated_message.text.should == "Updated stubbed message !"
      end

      scenario 'The updated message should appears in updater form' do
        page.find('#jaganizer_updater input').value.should == @updated_message[:id]
        page.find('#jaganizer_updater textarea').value.should == "Updated stubbed message !"
      end
    end
  end
end