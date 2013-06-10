require 'spec_helper'

describe Devise::SessionsController do
  def create_user
    post_data = {
       'user[email]'                 => 'person@example.com',
       'user[password]'              => 'secret',
       'user[password_confirmation]' => 'secret'
    }
    post '/users', post_data
  end
  
  def login
    post_data = {
       'user[email]'                 => 'person@example.com',
       'user[password]'              => 'secret',
       'user[password_confirmation]' => 'secret'
    }
    post '/users/sign_in', post_data
  end
  
  def logout
    delete '/users/sign_out'
  end
  
  def i_should_be_logged_in
    controller.user_signed_in?.should be_true
    get '/'
    response.body.squish.should =~ /You are logged in as person@example.com/
  end

  def i_should_not_be_logged_in
    controller.user_signed_in?.should be_false
    get '/'
    response.body.squish.should =~ /You are logged out/
  end
    
  it "does not explode" do
  end
  
  it "allows user creation" do
    User.count.should == 0
    create_user
    response.status.should == 302
    get response.redirect_url
    User.count.should == 1
    response.body.squish.should =~ /You are logged in as person@example.com/
    response.body.squish.should =~ /You have signed up successfully/
  end
  
  it "allows user logout" do
    create_user
    i_should_be_logged_in
    logout
    response.status.should == 302
    i_should_not_be_logged_in
    response.body.squish.should =~ /Signed out successfully/
  end
  
  it "allows user login" do
    create_user
    logout
    i_should_not_be_logged_in
    login
    response.status.should == 302
    i_should_be_logged_in
    response.body.squish.should =~ /Signed in successfully/
  end
  
  it "uses the right session store class" do
    store = Rails.application.config.session_store
    store.session_class.to_s.should == "ActionDispatch::Session::#{ENV["MONGO_SESSION_STORE_ORM"].camelize}Store::Session"
  end
  
  it "stores the session in the sessions collection" do
    collection = db["sessions"]
    collection.find.count.should == 0
    create_user
    collection.find.count.should == 1
  end
  
  it "allows renaming of the collection that stores the sessions" do
    collection = db["dance_parties"]
    collection.find.count.should == 0
    MongoSessionStore.collection_name = "dance_parties"
    create_user
    collection.find.count.should == 1    
  end
end
