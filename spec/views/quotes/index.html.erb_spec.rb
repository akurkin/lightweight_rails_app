require 'spec_helper'

describe 'quotes/index', type: :view do

  before do
    @quote = Quote.new(quote: 'Test quote', author: 'Rspec')
  end

  it 'should render quote' do
    render
    expect(rendered).to match /#{@quote.quote}/
    expect(rendered).to match /#{@quote.author}/
  end
end