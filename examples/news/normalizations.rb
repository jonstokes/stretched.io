Extension.define "global/normalizations" do
  extension do
    def normalize_time(str)
      Time.parse(str).to_datetime.rfc3339 if str.present?
    end
  end
end
