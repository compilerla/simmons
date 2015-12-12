require 'rails_helper'
RSpec.describe AinShape, type: :model do

  let(:factory) { RGeo::Geographic.simple_mercator_factory() }

  before do
    point1 = factory.point(-118.273990, 34.038269) # 110 10 fwy intersection
    point2 = factory.point(-118.248650, 34.062815) #101 110 fwy intersection
    point3 = factory.point(-118.214149, 34.055181) # 10 5 fwy intersection
    point4 = factory.point(-118.222040, 34.030473) # 101 5 fwy intersection
    dtla_string = factory.line_string([point1, point2, point3, point4]) #line around dtla
    dtla_polygon = factory.polygon(dtla_string) # polygon of dtla
    @dtla_model = AinShape.create(ain: '1234567890', shape: dtla_polygon)

    point1 = factory.point(-118.291641, 34.061779) # wilshire vermont
    point2 = factory.point(-118.279915, 34.051794) # olympic alvarado
    point3 = factory.point(-118.276798, 34.069452) # beverly rampart
    mcarthur_string = factory.line_string([point1, point2, point3]) #line around mcarthur park
    mcarthur_polygon = factory.polygon(mcarthur_string) # polygon of mcarthur
    @mcarthur_model = AinShape.create(ain: '2345678901', shape: mcarthur_polygon)
  end

  context '#containing_point' do
    let(:mcarthur_point) { factory.point(-118.277200, 34.058933) }
    let(:nickel_diner_point) { factory.point(-118.248243, 34.045488) }
    let(:hollywood_point) { factory.point(-118.317468, 34.088877) }

    it 'should return the model that contains the point' do
      expect(
        AinShape.containing_point(nickel_diner_point).first
      ).to eq @dtla_model
      expect(
        AinShape.containing_point(nickel_diner_point).count
      ).to eq 1

      expect(
        AinShape.containing_point(mcarthur_point).first
      ).to eq @mcarthur_model

      expect(
        AinShape.containing_point(mcarthur_point).count
      ).to eq 1
    end

    it 'should return nil if the point is not in a shape' do
      expect(
        AinShape.containing_point(hollywood_point).first
      ).to eq nil
    end
  end
end
