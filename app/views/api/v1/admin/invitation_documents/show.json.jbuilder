json.status "success"
json.data do
  json.document do
    json.id            @document.id
    json.invitation_id @document.invitation_id
    json.meta          @document.meta
    json.document      @document.document
  end
end
