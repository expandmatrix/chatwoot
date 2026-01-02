module EM
  class MessageCreatedWebhookJob < ApplicationJob
    queue_as :default

    def perform(message_id)
      message = Message.find_by(id: message_id)
      return unless message
      return unless message.incoming? && !message.private?
      payload = message.webhook_data
      raw = payload.to_json
      EM::WebhookClient.new.post_message_created(raw)
    end
  end
end
