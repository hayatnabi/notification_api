require 'net/http'

class Api::V1::NotificationsController < ApplicationController
  def create
    title = params[:title]
    text = params[:text]
    target_ip = params[:target_ip]

    if title.blank? || text.blank? || target_ip.blank?
      return render json: { error: 'Missing parameters' }, status: :bad_request
    end

    notification = Notification.create(title:, text:, target_ip:, status: 'pending')

    begin
      # Send POST request to remote machine
      uri = URI("http://#{target_ip}:4567/receive_notification")
      res = Net::HTTP.post(uri, { title:, text: }.to_json, "Content-Type" => "application/json")

      if res.is_a?(Net::HTTPSuccess)
        notification.update(status: 'delivered')
        render json: { message: 'Notification sent', status: res.code }, status: :ok
      else
        notification.update(status: 'failed')
        render json: { error: 'Failed to deliver', response: res.body }, status: :bad_gateway
      end
    rescue => e
      notification.update(status: 'error')
      render json: { error: 'Exception occurred', message: e.message }, status: :internal_server_error
    end
  end
end
