namespace :data do
  desc "match masterrecord to ain_shapes and add matches to AinShapeMasterRecord"
  task dedupe: :environment do
    MasterRecord.not_yet_matched.find_each do |master_record|
      ain_match = AinShape.where(ain: master_record.apn_given).first
      if ain_match
        AinShapesMasterRecord.create(master_record_id: master_record.id,
                                     ain_shape_id: ain_match.id,
                                     match_method: 'ain match')
        p "ain match"
      else
        inclusion_match = AinShape.find_by_lat_lon(master_record.address_latitude,
                                                   master_record.address_longitude).first
        if inclusion_match
          AinShapesMasterRecord.create(master_record_id: master_record.id,
                                        ain_shape_id: inclusion_match.id,
                                         match_method: 'point in shape')
        p "point match"
        end
      end
    end
  end
end
