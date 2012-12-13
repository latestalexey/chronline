###
# Given step definitions
###

Given /^there exist (\d+) articles?$/ do |n|
  @articles = FactoryGirl.create_list(:article, n.to_i)
end

Given /^there exists an article$/ do
  @article = FactoryGirl.create(:article)
end

Given /^I am on the new article page$/ do
  port = Capybara.current_session.driver.app_server.port
  visit new_admin_article_url(subdomain: :admin, host: 'lvh.me', port: port)
end

Given /^I am on the edit article page$/ do
  port = Capybara.current_session.driver.app_server.port
  visit edit_admin_article_url(@article, subdomain: :admin, host: 'lvh.me', port: port)
end

Given /^I am on the article index page$/ do
  port = Capybara.current_session.driver.app_server.port
  visit admin_articles_url(subdomain: :admin, host: 'lvh.me', port: port)
end


###
# When step definitions
###

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
 fill_in field, with: value
end

When /^I leave "(.*?)" empty$/ do |field|
 fill_in field, with: nil
end

When /^I click "(.*?)"$/ do |button|
  begin
    click_button button
  rescue Capybara::ElementNotFound
    click_link button
  end
end

When /^I enter a valid article$/ do
  @article = FactoryGirl.build(:article)
  fill_in 'Title', with: @article.title
  fill_in 'Subtitle', with: @article.subtitle
  fill_in 'Teaser', with: @article.teaser
  fill_in 'Body', with: @article.body
  select @article.section[0], from: 'article_section_0'
  select @article.section[1], from: 'article_section_1'
  select (@article.section[2] || ''), from: 'article_section_2'
end

When /^I make valid changes$/ do
  @article.subtitle = "Starter Pokemon already taken"
  @article.teaser = "Ash arrived too late"
  @article.body = "**Pikachu** wrecks everyone."
  @article.section = "/sports/"

  fill_in 'Subtitle', with: @article.subtitle
  fill_in 'Teaser', with: @article.teaser
  fill_in 'Body', with: @article.body
  select @article.section[0], from: 'article_section_0'
end


###
# Then step definitions
###

Then /^the "(.*?)" field should show an error$/ do |field|
  find_field(field).find(:xpath, '../..')[:class].should include('error')
end

Then /^the "(.*?)" field should be set to "(.*?)"$/ do |field, value|
  find_field(field).value.should == value
end

Then /^a new Article should be created$/ do
  Article.count.should == 1
end

Then /^the article should have the correct properties$/ do
  article = Article.find_by_title @article.title
  article.subtitle.should == @article.subtitle
  article.teaser.should == @article.teaser
  article.section.should == @article.section
  article.body.should == @article.body
end

Then /^I should see a listing of articles sorted by creation date$/ do
  Article.order("created_at DESC").each_with_index do |article, i|
    page.find("tr:nth-child(#{i + 1})").text.should include(article.title)
  end
end

Then /^they should have links to edit pages$/ do
  @articles.each do |article|
    row = page.find('tr', text: article.title)
    row.should have_link('Edit', href: edit_admin_article_path(article))
  end
end

Then /^they should have links to delete them$/ do
  @articles.each do |article|
    row = page.find('tr', text: article.title)
    row.should have_link('Delete')
  end
end

Then /^I should see the fields with article information$/ do
  find_field('Title').value.should == @article.title
  find_field('Subtitle').value.should == @article.subtitle
  find_field('Teaser').value.should == @article.teaser
  find_field('Body').value.should == @article.body
  find_field('article_section_0').value.should == @article.section[0]
  find_field('article_section_1').value.should == @article.section[1]
  find_field('article_section_2').value.should == (@article.section[2] || '')
end

Then /^article should no longer exist$/ do
  article_finder = lambda { Article.find(@article.id) }
  article_finder.should raise_error(ActiveRecord::RecordNotFound)
end

Then /^I should be on the article manage page$/ do
  current_path.should == admin_articles_path
end

Then /^I should see a deletion success message$/ do
  find('.alert').text.should include("Article \"#{@article.title}\" was deleted")
end