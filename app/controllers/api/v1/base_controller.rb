module Api
  module V1
    class BaseController < ApplicationController
      include JwtAuth
    end
  end
end
