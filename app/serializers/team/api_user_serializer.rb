# frozen_string_literal: true

class Team::ApiUserSerializer < ApplicationSerializer

  attributes :id, :username, :description, :enabled?

  delegate :id,
           :username,
           :description,
           :enabled?,
           to: :object
end
