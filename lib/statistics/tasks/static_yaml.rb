module Statistics
  module Tasks
    class StaticYaml
      def self.delete_event_histories(_period)
        EventHistory.for(:static_yaml).delete_all
      end

      def initialize(dojos, _date, _weekly)
        @client = Providers::StaticYaml.new
        @dojos = dojos
      end

      def run
        @dojos.each do |dojo|
          # dojo_event_serviceを特定してしまう必要がある、下手するとバグる？
          dojo.dojo_event_services.each do |dojo_event_service|
            @client.fetch_events.each do |e|
              EventHistory.create!(dojo_id: dojo.id,
                                   dojo_name: dojo.name,
                                   service_name: dojo_event_service.name,
                                   service_group_id: dojo_event_service.group_id,
                                   event_id: "#{dojo.id}_#{Time.zone.parse(e['evented_at']).to_i}",
                                   event_url: e['event_url']
                                   participants: e['participants'],
                                   evented_at: Time.zone.parse(e['evented_at']))
            end
          end
        end
      end
    end
  end
end
