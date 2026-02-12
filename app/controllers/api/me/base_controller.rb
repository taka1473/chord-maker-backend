class Api::Me::BaseController < ApplicationController
  before_action :authenticate!
end
