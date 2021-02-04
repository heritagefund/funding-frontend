require 'rails_helper'

RSpec.describe SalesforceApi::SalesforceApiClient do

  it 'should call the initialise_client private method when initialising the object' do

    allow_any_instance_of(SalesforceApi::SalesforceApiClient).to receive(:initialise_client)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    expect(salesforce_api_client).to have_received(:initialise_client).with(no_args).once

  end

  it 'should set the @client instance variable equal to the result from Restforce.new' \
     ' as part of initialising the object' do

    allow(Restforce).to receive(:new).with(any_args).and_return('test')

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    expect(salesforce_api_client.instance_variable_get(:@client)).to eq('test')

  end

  it 'should return a Hash when the Restforce client select query is successful' do

    restforce_response = double(
      Grant_Award__c: '15000',
      Grant_Percentage__c: '100'
    )

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_return(restforce_response)

    expect(salesforce_api_client.get_payment_related_details('guid'))
      .to eq( { 'grant_award': '15000', 'grant_percentage': '100' } )

  end

  it 'should raise an exception if the Restforce client select query does not find a matching Case object' do

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_raise(Restforce::NotFoundError.new('1', 'test'))

    expect(Rails.logger).to receive(:error).once

    expect { salesforce_api_client.get_payment_related_details('guid') }
      .to raise_error(an_instance_of(Restforce::NotFoundError).and having_attributes(response: 'test'))

  end

  it 'should raise an exception if the Restforce client select query raises a MatchesMultipleError exception' do

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_raise(Restforce::MatchesMultipleError.new('1', 'test'))

    expect(Rails.logger).to receive(:error).once

    expect { salesforce_api_client.get_payment_related_details('guid') }
      .to raise_error(an_instance_of(Restforce::MatchesMultipleError).and having_attributes(response: 'test'))

  end

  it 'should raise an exception if the Restforce client select query raises a UnauthorizedError exception' do

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_raise(Restforce::UnauthorizedError.new('test'))

    expect(Rails.logger).to receive(:error).once

    expect { salesforce_api_client.get_payment_related_details('guid') }
      .to raise_error(an_instance_of(Restforce::UnauthorizedError))

  end

  it 'should raise an exception if the Restforce client select query raises a EntityTooLargeError exception' do

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_raise(Restforce::EntityTooLargeError.new('1', 'test'))

    expect(Rails.logger).to receive(:error).once

    expect { salesforce_api_client.get_payment_related_details('guid') }
      .to raise_error(an_instance_of(Restforce::EntityTooLargeError).and having_attributes(response: 'test'))

  end

  it 'should raise an exception if the Restforce client select query raises a ResponseError exception' do

    allow(Restforce).to receive(:new).with(any_args).and_return(double)

    salesforce_api_client = SalesforceApi::SalesforceApiClient.new()

    allow(salesforce_api_client.instance_variable_get(:@client))
      .to receive(:select).and_raise(Restforce::ResponseError.new('1', 'test'))

    expect(Rails.logger).to receive(:error).once

    expect { salesforce_api_client.get_payment_related_details('guid') }
      .to raise_error(an_instance_of(Restforce::ResponseError).and having_attributes(response: 'test'))

  end

end