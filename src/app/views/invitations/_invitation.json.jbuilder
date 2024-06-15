json.extract! invitation, :id, :uuid, :name, :code, :uses, :max_uses, :expires_at, :deleted, :created_at, :updated_at
json.url invitation_url(invitation, format: :json)
