Extension.define "global/normalizations" do
  extension do
    def normalize_time(str)
      Time.parse(str) if str.present?
    end
  end
end
