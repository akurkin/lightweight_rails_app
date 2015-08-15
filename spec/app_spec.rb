require 'spec_helper'

describe QuotesController, type: :controller do
  context 'GET index' do
    before(:each) do
      Quote.delete_all
    end

    let!(:quote) { Quote.create!(quote: 'Test quote', author: 'Rspec') }

    before do
      get :index
    end

    it 'should assign quote' do
      expect(assigns(:quote).attributes.except('updated_at', 'created_at')).
        to match(quote.attributes.except('updated_at', 'created_at'))
    end

    it { expect(response).to render_template('index') }
  end
end

describe QuoteOfTheDay, type: :routing do
  it { expect(get: '/').to route_to(controller: 'quotes', action: 'index') }
  it { expect(get: '/quotes').to route_to(controller: 'quotes', action: 'index') }
end
