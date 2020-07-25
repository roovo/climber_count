Sequel.migration do
  change do
    create_table :occupancy_counts do
      primary_key :id
      Integer     :climber_count,     null: false
      Timestamp   :created_at,        null: false,  size: 0
    end
  end
end
