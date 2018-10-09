class CustomerInterest < ApplicationRecord

  include AlgoliaSearch

  algoliasearch per_environment: true do
    attribute :name
    searchableAttributes ['name']
  end

end
