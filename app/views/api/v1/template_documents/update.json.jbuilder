json.status "success"
json.data do
  json.document do
    json.id          @document.id
    json.template_id @document.template_id
    json.meta        @document.meta
    json.document    @document.document
  end
end
