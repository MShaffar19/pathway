Given(/^the following assessments:$/) do |table|
  table.hashes.each do |attributes|
    attributes.merge!(user_id: @current_user.id) unless attributes[:user_id].present?
    complete = attributes.delete("completed")
    assessment = FactoryGirl.create(:assessment, attributes)
    if complete == "yes"
      AssessmentAnswer.create( assessment: assessment, question: Question.first, answer: Answer.find_by_code("Q1.2") )
      assessment.complete
    end
  end
end

Given(/^the current assessment is ready for completion$/) do
  AssessmentAnswer.create( assessment: @current_user.current_assessment, question: Question.first, answer: Answer.find_by_code("Q1.2") )
end

When(/^I complete the assessment$/) do
  all('.complete').first.click
end

When(/^I delete an assessment$/) do
  all('.assessment')[0].first(:link, "Delete").click
end

Then(/^I should see "(.*?)" assessments$/) do |count|
  expect(page).to have_selector('.assessment', count: count)
end

Given(/^the current assessment is completed$/) do
  AssessmentAnswer.create( assessment: @current_user.current_assessment, question: Question.first, answer: Answer.find_by_code("Q1.2") )
  @current_user.current_assessment.complete
end

Then(/^the element with id "(.*?)" should have the content "(.*?)"$/) do |selector, text|
  page.assert_selector(selector, :text => text)
end

When(/^there should be "(.*?)" themes in the "(.*?)" section$/) do |count, section|
  page.assert_selector(".activities .theme", :count => count.to_i)
end

Then(/^there should be "(.*?)" items listed in "(.*?)"$/) do |count, selector|
  page.assert_selector("#{selector} li", :count => count.to_i)
end

Then(/^I should see a link to share the report$/) do
  page.assert_selector("#share-report-link")
end

When(/^I click on the sharing link for the "(.*?)" assessment$/) do |title|
  assessment = Assessment.where(title: title).first
  path = "/assessments/#{assessment.id}/report?token=#{assessment.token}"
  visit path
end

When(/^I click on the "(.*?)" link$/) do |text|
  click_link text
end

Then(/^the response should be "(.*?)"$/) do |code|
  expect(page.status_code).to eq(code.to_i)
end

Then(/^I should see a CSV$/) do
  expect(page.response_headers['Content-Type']).to match /text\/csv/
end

Then(/^the CSV link should not contain a token$/) do
  link = find("a", text: /Download summary scores/)

  expect(link[:href]).to_not match(/token=/)
end
